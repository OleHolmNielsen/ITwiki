#
# Create Linux ipset data file for geoblocking with iptables firewall
# Ipset homepage: http://ipset.netfilter.org/
# Download this file from page https://wiki.fysik.dtu.dk/it/Linux_firewall_configuration
# Author: Ole.H.Nielsen@fysik.dtu.dk
# Version: 18-Feb-2015
#

# Blacklisted contries (example only).
# See the full list of country zones at http://www.ipdeny.com/ipblocks/
COUNTRYLIST=ae ar bd bg bh br cl cn co cr ec eg ge hk id il in ir jp kr kz lt lv mx my pa pe pk py ru sa sd sk th tn tr tw ua vn za

# Geo zones are from http://www.ipdeny.com/ipblocks/
WGET=/usr/bin/wget --timestamping
SITE=http://www.ipdeny.com/ipblocks/data/countries
ZONES=all-zones.tar.gz
ZONEDIR=zones
# RHEL6/CentOS6 ipset data file
IPSET=/etc/sysconfig/ipset

default: ${IPSET}

# Create a new ipset data file
${IPSET}: ${ZONES} sanitycheck
	echo "create geoblock hash:net" > $@
	@for c in ${COUNTRYLIST}; \
	do \
		echo Adding country zone file ${ZONEDIR}/$$c.zone to ipset ; \
		cat ${ZONEDIR}/$$c.zone | awk '{printf("add geoblock %s\n", $$1)}' >> $@; \
	done
	@echo ipset file written:
	@ls -l ${IPSET}

# Update the country zone files from the web and extract to subdir zones
${ZONES}: FRC
	${WGET} ${SITE}/${ZONES}
	rm -rf zones; mkdir zones
	(cd zones; tar xzf ../all-zones.tar.gz)

# Sanity checks:
sanitycheck:
	@for c in ${COUNTRYLIST}; \
	do \
	if test ! -s ${ZONEDIR}/$$c.zone; \
	then \
		echo ERROR: No such zone file: ${ZONEDIR}/$$c.zone; \
		exit 1; \
	fi; \
	done

FRC:

clean:
	rm -rf all-zones.tar.gz zones 
