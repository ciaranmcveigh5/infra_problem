#!groovy

def sout = new StringBuffer(), serr = new StringBuffer()

def proc ='/tmp/key.sh'.execute()

proc.consumeProcessOutput(sout, serr)
proc.waitForOrKill(1000)
