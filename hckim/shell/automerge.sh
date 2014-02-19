#######################
# User Configuration
#######################

TEMPORARY_BRANCH=my_temp_branch_567891234
GERRIT_ADDRESS=hdbgerrit.wdf.sap.corp
GERRIT_PORT=29418

GERRIT_USER_NAME=
SINGLE_PUSH_AT_A_TIME=0
INTERMEDIATE_BRANCH=
SOURCE_BRANCH=
TARGET_BRANCH=
WORKSPACE=

usage()
{
    echo "Option:"
    echo "  w: Workspace path"
    echo "  i: Intermediate local branch name"
    echo "  s: Source branch name"
    echo "  t: Target branch name"
    echo "  a: Gerrit server address"
    echo "  p: Gerrit server port"
    echo "  u: Gerrit user"
    echo "  c: Only single push is allowed at a time (don't allow multiple merge push in a gerrit queue)"
}

dump_conf()
{
    echo "WORKSPACE: $WORKSPACE"
    echo "SOURCE BRANCH: $SOURCE_BRANCH"
    echo "TARGET BRANCH: $TARGET_BRANCH"
    echo "INTERMEDIATE BRANCH: $INTERMEDIATE_BRANCH"
    echo "TEMPORARY_BRANCH: $TEMPORARY_BRANCH"
    echo "GERRIT_ADDRESS: $GERRIT_ADDRESS"
    echo "GERRIT_PORT: $GERRIT_PORT"
    echo "GERRIT_USER_NAME: $GERRIT_USER_NAME"
    echo "SINGLE_PUSH_AT_A_TIME: $SINGLE_PUSH_AT_A_TIME"
}

while getopts "h:w:i:s:t:a:p:u:c" flag
do
    case $flag in
    "h")
        usage
        exit 0
        ;;
    "w")
        WORKSPACE=$OPTARG
        ;;
    "i")
        INTERMEDIATE_BRANCH=$OPTARG
        ;;
    "s")
        SOURCE_BRANCH=$OPTARG
        ;;
    "t")
        TARGET_BRANCH=$OPTARG
        ;;
    "a")
        GERRIT_ADDRESS=$OPTARG
        ;;
    "p")
        GERRIT_PORT=$OPTARG
        ;;
    "u")
        GERRIT_USER_NAME=$OPTARG
        ;;
    "c")
        SINGLE_PUSH_AT_A_TIME=1
        ;;
    esac
done

if [ "$WORKSPACE" == "" ]; then
    usage
    exit 1
fi
if [ "$SOURCE_BRANCH" == "" ]; then
    usage
    exit 1
fi
if [ "$TARGET_BRANCH" == "" ]; then
    usage
    exit 1
fi
if [ $SINGLE_PUSH_AT_A_TIME -ne 0 ]; then
    if [ "$GERRIT_ADDRESS" == "" ]; then
        echo "Gerrit server address is required"
        usage
        exit 1
    fi
    if [ "$GERRIT_USER_NAME" == "" ]; then
        echo "Gerrit user name is required"
        usage
        exit 1
    fi
fi

INTERMEDIATE_BRANCH=${SOURCE_BRANCH}2${TARGET_BRANCH}
last_change_id_file="$WORKSPACE/${SOURCE_BRANCH}2${TARGET_BRANCH}.lastchangeid"


#######################
# Environment 
#######################
TREX_BASE=$WORKSPACE/sys/src

source $TREX_BASE/../../.iprofile

log()
{
    echo "[`date +%G%m%d%H%M%S`] $1"
}

check_merge_conflict()
{
    for s in `git status --porcelain | cut -b 1-2 | grep -v ??`
    do
        if [ ${#s} -gt 1 ]; then # merge conflict
            return 1
        fi
    done

    return 0
}

check_uncommitted_files()
{
    local NUM_NOTCOMMITED_FILES=`git status --porcelain | cut -b 1-2 | grep -v ?? | wc -l`

    return $NUM_NOTCOMMITED_FILES;
}

git_current_branch()
{
    local original_branch=`git branch | grep ^\* | cut -d' ' -f2`
    echo $original_branch
}

git_clean_checkout_branch()
{
    local branch=$1
    local source_branch=$2
    local tmp_branch=$3

    current_branch=`git_current_branch`
    if [ $branch == $current_branch ]; then
        git checkout -b $tmp_branch
        err=$?; if [ $err -ne 0 ]; then return $err; fi
    fi

    local is_exist=`git branch | grep -w $branch | wc -l`

    if [ $is_exist -ne 0 ]; then
        git branch -D $branch
        err=$?; if [ $err -ne 0 ]; then return $err; fi
    fi

    git checkout -b $branch origin/$source_branch
    err=$?; if [ $err -ne 0 ]; then return $err; fi

    if [ $branch == $current_branch ]; then
        git branch -D $tmp_branch
        err=$?; if [ $err -ne 0 ]; then return $err; fi
    fi

    return 0
}

gerrit_is_open_change()
{
    local gerrit_address=$1
    local gerrit_port=$2
    local gerrit_user_name=$3
    local gerrit_change_id=$4

    cmd="ssh ${gerrit_user_name}@${gerrit_address} -p ${gerrit_port} gerrit query change:${gerrit_change_id} is:open"
    echo $cmd
    gerrit_status=`$cmd`

    echo "$gerrit_status"

    local cnt=`echo "$gerrit_status" | grep "^rowCount:" | awk '{print $2;}'`
    echo $cnt

    if [ "$cnt" == "" ]; then
        cnt=0
    fi

    return $cnt
}

git_merge()
{
    local err=0

    log "Fetch repository"
    git fetch

    git_clean_checkout_branch ${INTERMEDIATE_BRANCH} ${TARGET_BRANCH} ${TEMPORARY_BRANCH}
    err=$?; echo "Return $err"; if [ $err -ne 0 ]; then log "git operation failed ($err)"; return 1; fi

    log "Merge from $SORCE_BRANCH"
    git merge --no-ff --no-commit origin/${SOURCE_BRANCH}
    err=$?; echo "Return $err"; if [ $err -ne 0 ]; then log "git operation failed ($err)"; return 1; fi

    local num_changes=`git status --porcelain | cut -b 1-2 | grep -v ?? | wc -l`

    log "$num_changes changes merged"

    if [ $num_changes -le 0 ]; then
        log "No change were merged. Merge ignored"
        return 0
    fi

    log "Check merge conflict"
    check_merge_conflict
    if [ $? -ne 0 ]; then
        log "Merge conflicts detected!"
        git status
        return 1
    fi


    git status

    log "Commit merge"
    timestamp=`date +"%Y-%m-%d"`
    git commit -m "Merge remote-tracking branch 'origin/$SOURCE_BRANCH' into $TARGET_BRANCH - $timestamp [auto-merge]"
    err=$?; echo "Return $err"; if [ $err -ne 0 ]; then log "git operation failed ($err)"; return 1; fi

    msg=`git push gerrit HEAD:refs/for/${TARGET_BRANCH} 2>&1`
    err=$?; echo "$msg"; echo "Return $err"; if [ $err -ne 0 ]; then log "git operation failed ($err)"; return 1; fi
    

    echo "$msg" > $WORKSPACE/t.txt
    local change_id=`echo "$msg" | grep "^remote: New Changes:" -A 1 | tail -n 1 | tr -cd '\11\12\40-\176' | cut -d '/' -f 4 | cut -d '[' -f1`
    echo "Change ID is $change_id"

    echo "Saving Change ID $change_id into $last_change_id_file"
    echo $change_id > $last_change_id_file
    err=$?; echo "Return $err"; if [ $err -ne 0 ]; then log "Saving Change ID failed ($err)"; return 1; fi

    return 0
}

backup_n_merge()
{
    local original_branch=`git branch | grep ^\* | cut -d' ' -f2`

    check_uncommitted_files
    local uncommitted_files=$?

    if [ $uncommitted_files -ne 0 ]; then
        echo "$INTERMEDIATE_BRANCH has uncommitted files, and will be stashed"
        git stash
    fi

    git_merge

    if [ $? -ne 0 ]; then
        log "Merge from $SOURCE_BRANCH to $TARGET_BRANCH is failed. Leave branch $INTERMEDIATE_BRANCH as it is. Please resolve merge conflict manually"
        
        if [ $uncommitted_files -ne 0 ]; then
            log "Original branch $original_branch had uncommited files, and stashed"
        fi
    else
        log "Merge from $SOURCE_BRANCH to $TARGET_BRANCH succeeded"

        if [ $uncommitted_files -ne 0 ]; then
            if [ $original_branch == $INTERMEDIATE_BRANCH ]; then
                log "Intermediate branch ($INTERMEDIATE_BRANCH) had uncommited files, but not unstashed"
            else
                log "Uncommitted files in $original_brach will be unstashed"
                git stash pop
            fi
        fi
    fi
}

check_previous_push()
{
    if [ -f $last_change_id_file ]; then
        last_change_id=`cat $last_change_id_file`
        gerrit_is_open_change $GERRIT_ADDRESS $GERRIT_PORT $GERRIT_USER_NAME $last_change_id

        if [ $? -eq 0 ]; then
            echo "$last_change_id is closed"
            return 1
        fi
        echo "$last_change_id is still open"
    else
        echo "cannot find $last_change_id_file. It's assumed that this is the first merge."
        return 1
    fi

    return 0
}

log "=== Begin of merge $SOURCE_BRANCH to $TARGET_BRANCH"
cd $TREX_BASE

if [ $SINGLE_PUSH_AT_A_TIME -ne 0 ]; then
    check_previous_push
    if [ $? -eq 0 ]; then
        echo "Previous merge is still on Gerrit queue. merge process is stopped"
        exit 1
    fi
fi

backup_n_merge

log "=== End of merge $SOURCE_BRANCH to $TARGET_BRANCH"
