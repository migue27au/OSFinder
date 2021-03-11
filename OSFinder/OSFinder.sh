#!/bin/bash

ip=$(echo $1);
timeout=$(echo $2)
verbose=$(echo $3);

ttl=0;
jumps=0;



if [ -z $timeout ]; then
	timeout=0.1
fi


if [ -z $verbose ]; then
	verbose=0
fi



if [ $verbose -eq 1 ]; then
	echo "Scanning IP: $ip";

fi

if [ ! -z $ip ]; then
	for i in {1..255..1}; do
		pingOutput=$(echo "$(ping $ip -c 1 -W $timeout -t $i)" | grep -v -E "0% packet loss|ping statistics ---|bytes of data|rtt min/avg/max/mdev")
		#echo "Respuesta -> $pingOutput"
		
		
		ICMPttl=$(echo $pingOutput | grep "Time to live exceeded");
		
		if [ $verbose -eq 1 ]; then
			echo "ttl -> $i"
			echo "ICMP -> $ICMPttl"
		fi
		

		if [ ! -z "$pingOutput" ]; then
			if [ ! -z "$ICMPttl" ]; then
				if [ $verbose -eq 1 ]; then
					echo "Time to live exceeded"
				fi
			else
				if [ $verbose -eq 1 ]; then
					echo "Ok -> $pingOutput";
				fi

				jumps=$i
				ttl=$(echo $pingOutput | cut -d ' ' -f 7 | cut -d "=" -f 2)
				break
				
			fi
		else
			if [ $verbose -eq 1 ]; then
				echo "no response"
			fi
		fi
	done
else
	echo "necesaria ip"
fi

initialTtl=$(expr $jumps + $ttl)

if [ $verbose -eq 1 ]; then
	echo "jumps $jumps"
	echo "ttl $ttl"
	echo "initialTtl $initialTtl"
fi

if [ $initialTtl -eq 63 ] || [ $initialTtl -eq 62 ]; then
	echo "OS -> Linux 2.0.x kernel/MacOS/MacTCP	(ttl=$initialTtl)"
else
	if [ $initialTtl -eq 127 ] || [ $initialTtl -eq 126 ]; then
		echo "OS -> Windows/Foundry (ttl=$initialTtl)"
	else
		if [ $initialTtl -eq 199 ]; then
			echo "OS -> MPE/IX (HP)	 (ttl=$initialTtl)"
		else
			if [ $initialTtl -eq 254 ]; then
				echo "OS -> Solaris/AIX/BSDI/FreeBSD/HP-UX/Irix/Linux 2.2.14 kernel/Linux 2.4 kernel/NetBSD/OpenVMS/Stratus/SunOS/Ultrix (ttl=$initialTtl)"
			else
				echo "OS -> not found (ttl=$initialTtl)"
			fi
		fi
	fi
fi

