mkdir /cnfs
mkdir /cnfs/TIM_DATA3
mkdir /cnfs/DEV_TOOL
mkdir /cnfs/HDB_POOL
mkdir /cnfs/TESTDATA
mkdir /cnfs/area51
mkdir /cnfs/home

mkdir /sharedstoreage
mkdir /sharedstoreage/selxeon4
mkdir /sharedstoreage/selxeon5
mkdir /sharedstoreage/selxeon4/INT1
mkdir /sharedstoreage/selxeon4/INT2
mkdir /sharedstoreage/selxeon5/INT1
mkdir /sharedstoreage/selxeon5/INT2

rm -R /TIM_DATA3
rm -R /DEV_TOOL
rm -R /HDB_POOL
rm -R /TESTDATA
rm -R /area51
rm -R /home2
rm -R /sapmnt

ln -s /cnfs/TIM_DATA3 /TIM_DATA3
ln -s /cnfs/DEV_TOOL /DEV_TOOL
ln -s /cnfs/HDB_POOL /HDB_POOL
ln -s /cnfs/TESTDATA /TESTDATA
ln -s /cnfs/area51 /area51
ln -s /cnfs/home /home2
ln -s /cnfs/DEV_TOOL/sapmnt /sapmnt

rm -R /MD1200_1
rm -R /MD1200_2
rm -R /MD3200_1
rm -R /MD3200_2

ln -s /sharedstoreage/selxeon4/INT1 /MD1200_1
ln -s /sharedstoreage/selxeon4/INT2 /MD1200_2
ln -s /sharedstoreage/selxeon5/INT1 /MD3200_1
ln -s /sharedstoreage/selxeon5/INT2 /MD3200_2
