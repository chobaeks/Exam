#!/usr/bin/python
class Animal(object):
	print "hckim"

	def __init__(self):
		print("Animal __init()")
	def hckim(self):
		print("test")

class Tiger(Animal):
    def __init__(self):
        super(Tiger, self).__init__()
        print("Tiger __init__()")

class Lion(Animal):
    def __init__(self):
        super(Lion, self).__init__()
        print("Lion __init__()")

class Liger(Tiger, Lion):
    def __init__(self):
        super(Liger, self).__init__()
        print self.__class__.__mro__
        print("Liger __init__()")

a = Liger();
