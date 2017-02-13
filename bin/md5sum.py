#!/usr/bin/env python

##############################################################################
# File:       md5sum.py
# Language:   Python
# Time-stamp: <2012-03-20 23:16:12 lockharm>
# Platform:   N/A
# OS:         N/A
# Authors:    Michael Lockhart [MJL]    (michael.lockhart@hp.com)
#
# Rights:     COPYRIGHT (c) 2011, 2012 HEWLETT-PACKARD DEVELOPMENT COMPANY.
#             ALL RIGHTS RESERVED.
#
# PURPOSE:    A replacement md5 hash utility, similar to md5sum
#
#             usage:
#                   md5sum <filename> [..]
#                   use '-' to sum standard input
#              -or-
#                   md5sum -c <manifest>
#
# HISTORY:
#
# MJL20110307 - Created.
# MJL20120320 - Ignore comments (lines starting with '#') and empty lines
#             - Print the file being checksummed before the outcome
#             - twirling baton for manifest checks
#

import md5
import sys
import string

def md5hash(fobj):
    '''Returns an md5 hash for an open object, fobj, using it's read
    method.'''
    m5 = md5.new()
    count = 0
    while True:
        data = fobj.read(8096)
        if not data:
            break
        m5.update(data)
        count += 1
        twirl_baton(count)
    remove_baton()
    return m5.hexdigest()

baton = '\|/-'
def twirl_baton(counter):
    if g_twirl and (counter % 2049 == 0):
        sys.stdout.write(chr(8) + baton[counter % 4]); sys.stdout.flush()

def remove_baton():
    if g_twirl:
        sys.stdout.write(chr(8)); sys.stdout.flush()

def md5sum(filespec):
    '''Returns an md5 hash for file filespec, or stdin if filespec is
    "-".'''
    m5 = 0
    if filespec == '-':
        m5 = md5hash(sys.stdin)
    else:
        try:
            f = file(filespec, 'rb')
            m5 = md5hash(f)
            f.close()
        except:
            print 'Failed to open file: ' + filespec
    return m5

def manifest(manifest_fspec):
    '''Processes an md5 manifest and checks the hashes against each
    file listed'''
    try:
        manifests = open(manifest_fspec, 'r')

        for line in manifests.readlines():
            if (line[0] != '#') and (len(line) > 4):
                item = string.split(line)  # first is the digest, then the
                print item[1] + ':\t',     # filespec; strip the asters
                if md5sum(string.replace(item[1],'*','')) == item[0]:
                    result = 'OK'
                else:
                    result = 'failed'
                print result

        manifests.close()
    except:
        print 'Failed to open manifest file: ' + manifest_fspec

### MAIN ###
if __name__ == '__main__':
    g_twirl = False
    if sys.argv[1] == '-c':
        g_twirl = True
        manifest(sys.argv[2])
    else:
        for filespec in sys.argv[1:]:
            print '%32s *%s' % (md5sum(filespec), filespec)
