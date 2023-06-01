SHORT=d:,c:,p:,h
LONG=domain:,company:,prefix:,help
OPTS=$(getopt -a -n weather --options $SHORT --longoptions $LONG -- "$@" 2>/dev/null)

domain_name=`echo $OPTS |  sed "s/' /\n/g" | grep -e "--domain\|-d" | sed -e "s/-h //g" | sed -e "s/--help //g" | sed "s/-d '//g" | sed "s/--domain '//g"`
company_name=`echo $OPTS | sed "s/' /\n/g" | grep -e "--company\|-c" | sed -e "s/-h //g" | sed -e "s/--help //g" | sed "s/-c '//g" | sed "s/--company '//g"`
prefix_name=`echo $OPTS | sed "s/' /\n/g" | grep -e "--prefix\|-p" | sed -e "s/-h //g" | sed -e "s/--help //g" | sed "s/-p '//g" | sed "s/--prefix '//g"`
if echo $OPTS | grep -i -q -e "\-\-help \|\-h "; then
	echo "Usage of domain verifier:
  -d --domain: File Name Of Your domains that you want verify them
  -c --company: File Name Of Aqusition And OrgNames That you verified before
  -p --prefix: File Name Of Ips And Cidrs Of your comapny
  -h --help: Guidance Of This Script How to use	"
else

	if [[ ! -z ${domain_name} ]];then
		for domain in $(cat $domain_name);
		do
			if [[ ! -z ${company_name} ]] ;then
				data=`whois $domain`
				if  echo $data | grep -q -i -f $company_name ; then
				    echo $domain >> verified_domain445566
				    continue
				elif  true ; then
		       	    data2=`echo | openssl s_client -showcerts -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -inform pem -noout -text`
		       	    if  echo $data2 | grep -q -i -f $company_name ; then
			   			echo $domain >> verified_domain445566
			   			continue
			    	fi
				fi
			fi
			if [[ ! -z ${prefix_name} ]] ; then
				for ip in $(dig +short $domain);
				do
				    for prefix in $(cat $prefix_name);
				    do
				    	if  echo $prefix | mapcidr -silent -match-ip $ip | grep -q $ip ; then
				    		echo $domain >> verified_domain445566
				    		continue 3
				    	fi
				    done
				done
		    fi
				

		done
		cat verified_domain445566 | sort -u
		rm -rf ns445566
		rm -rf verified_domain445566
	else
		echo "[-] Domain List File Not found"
		echo "Usage of domain verifier:
		  -d --domain: File Name Of Your domains that you want verify them
		  -c --company: File Name Of Aqusition And OrgNames That you verified before
		  -p --prefix: File Name Of Ips And Cidrs Of your comapny
		  -h --help: Guidance Of This Script How to use	"
	fi
fi
