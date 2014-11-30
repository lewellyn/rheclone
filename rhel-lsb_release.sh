#!/bin/sh

# (c) Copyright 2012, Matt Lewandowsky, GeekBakery.
# lewellyn@geekbakery.net http://geekbakery.net
# http://geekbakery.net/archives/2012/08/make-your-rhel-clone-look-legit-to-installers.geek

# Licensed under the Buena Onda License Agreement (BOLA).
# http://geekbakery.net/archives/2012/08/buena-onda-license-agreement.geek

# This is mostly to fool installers into thinking you run RHEL. Urg.
# It's also hideously ugly and really should be rewritten in something that
# lets you parse argv sanely. Really.
# Notably, it doesn't handle constructs such as "-as" instead of "-a -s".

### Here's the stuff you might want to fake.

# I don't think anything actually cares about the codename, so we give the
# underlying info from the distro's lsb_release.
CODENAMESTRING="`/usr/bin/lsb_release --short --codename`"

# This is used in a couple of different places, but should work as-is.
DISTRIBUTORSTRING="Red Hat Enterprise Linux"

# This may need to be changed to "RedHatEnterprise", but unlikely.
IDSTRING="RedHatEnterpriseLinux"

# If your RHEL-clone doesn't use the same release format, you may need to
# change this string to a hard-coded value, as appropriate. Note that if you
# do change this, you have to update this script each version upgrade.
RELEASESTRING="`/usr/bin/lsb_release --short --release`"

### END OF FAKEABLE STUFF. YOU PROBABLY WANT TO STOP HERE. ###

# There really aren't many user-serviceable parts below.
HELP=""
SHORT=""
ALL=""
VERSION=""
ID=""
DESCRIPTION=""
RELEASE=""
CODENAME=""

for option in "$@"; do
	case $option in
		# We can't break here, since --all or --short may be at the end.
		# Order is unimportant here, but consistency is good.

		# We have to escape the question mark, else it matches anything!
		--help|-h|-\?)
			HELP=1
			;;
		--short|-s)
			SHORT=1
			;;
		--all|-a)
			ALL=1
			;;
		--version|-v)
			VERSION=1
			;;
		--id|-i)
			ID=1
			;;
		--description|-d)
			DESCRIPTION=1
			;;
		--release|-r)
			RELEASE=1
			;;
		--codename|-c)
			CODENAME=1
			;;
		# Dunno about the specified option. Skip it.
		*)
			;;
	esac
done

# Probably should use a heredoc, but meh. This works with most sane systems.
if [ -n "$HELP" ]; then
	echo "
Fake lsb_release prints slightly altered LSB (Linux Standard Base) information.

USAGE:
	$0 [OPTION]...

NOTES:
	* With no OPTION, defaults to --version
	* Does not support combining short form options. Use "-s -a", not "-sa".
	* This isn't a general utility; but to fool installers into seeing RHEL.

OPTIONS:
	-h, -?, --help
		This help text.
	-s, --short
		Use short, parseable, output.
	-a, --all
		Display all information listed below.
	-v, --version
		Display compliant LSB version. (From OS lsb_release.)
	-i, --id
		Display distributor ID. (Faked.)
	-d, --description
		Display distribution description. (Faked.)
	-r, --release
		Display distribution release number. (From OS lsb_release.)
	-c, --codename
		Display distribution codename. (From OS lsb_release.)

For more information, please see:

http://geekbakery.net/archives/2012/08/make-your-rhel-clone-look-legit-to-installers.geek
"
	exit 23
fi
	
if [ -z "$ALL" -a -z "$VERSION" -a -z "$ID" -a -z "$DESCRIPTION" -a -z "$RELEASE" -a -z "$CODENAME" ]; then
	VERSION=1
fi

# Long output
if [ -z "$SHORT" ]; then
	if [ -n "$ALL" -o -n "$VERSION" ]; then
		# We probably want to "fake" the same versioning as we get from lsb_release, for compatiblity.
 		/usr/bin/lsb_release --version
	fi
	if [ -n "$ALL" -o -n "$ID" ]; then
 		echo "Distributor ID:	$DISTRIBUTORSTRING"
	fi
	if [ -n "$ALL" -o -n "$DESCRIPTION" ]; then
 		echo "Description:	$DISTRIBUTORSTRING release $RELEASESTRING ($CODENAMESTRING)"
	fi
	if [ -n "$ALL" -o -n "$RELEASE" ]; then
 		echo "Release:	$RELEASESTRING"
	fi
	if [ -n "$ALL" -o -n "$CODENAME" ]; then
 		echo "Codename:	$CODENAMESTRING"
	fi
fi

# Short output
if [ -n "$SHORT" ]; then
	if [ -n "$ALL" ]; then
		# --short --all outputs onto a single line.
 		echo "`/usr/bin/lsb_release --short --version` $IDSTRING \"$DISTRIBUTORSTRING release $RELEASESTRING ($CODENAMESTRING)\" $RELEASESTRING $CODENAMESTRING"
	fi
	if [ -n "$VERSION" ]; then
 		/usr/bin/lsb_release --short --version
	fi
	if [ -n "$ID" ]; then
 		echo "$IDSTRING"
	fi
	if [ -n "$DESCRIPTION" ]; then
 		echo "\"$DISTRIBUTORSTRING release $RELEASESTRING ($CODENAMESTRING)\""
	fi
	if [ -n "$RELEASE" ]; then
 		echo "$RELEASESTRING"
	fi
	if [ -n "$CODENAME" ]; then
 		echo "$CODENAMESTRING"
	fi
fi
