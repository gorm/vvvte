if [ -d /srv/www/wordpress-default ]
then
	cd /srv/www/wordpress-default 
	if ! egrep -q define.*\'MULTISITE\'.*true wp-config.php
	then
		echo "Transforming to multisite"
		wp core multisite-convert --title="My Network"
	else
		echo "Already multisite"
	fi

	if ! egrep -q define.*WPLANG.*nb_NO 
	then
		echo "Upgrade to Norwegian version"
		sed -i.bak "s/WPLANG',\s*'.*'/WPLANG', 'nb_NO'/" wp-config.php
		rm wp-config.php.bak
		wp core update
	fi
fi
