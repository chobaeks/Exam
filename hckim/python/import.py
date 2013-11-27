#!/usr/bin/python

from test import *

class Import(Service):
	test = 456
	
	def test1(self):
		print "%s" % (self.test)

Im = Import("hckim")
Im.test1()
