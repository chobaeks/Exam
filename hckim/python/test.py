#!/usr/bin/python

class Service:
	test = 123

	def __init__(self, name):
		self.name = name
	def sum(self, a, b):
		result =  a + b
		print "%s = %s" % (self.name, result)
	def __del__(self):
		print "%s end" % (self.name)

if __name__ == "__main__":
	pey = Service("hckim")
	pey.sum(1, 1)
	pey.test
