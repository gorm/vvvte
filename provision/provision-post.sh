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

	if ! egrep -q define.*WPLANG.*nb_NO  wp-config.php
	then
		echo "Upgrade to Norwegian version"
		sed -i.bak "s/WPLANG',\s*'.*'/WPLANG', 'nb_NO'/" wp-config.php
		rm wp-config.php.bak
		wp core update
	fi

	if [ ! -d /srv/www/regno ]
	then
		echo "Downloading regno plugins"
		git clone https://github.com/blgrgjno/main-blog-network.git /srv/www/regno
		echo "Copy plugins"
		cp -R /srv/www/regno/plugins/* /srv/www/wordpress-default/wp-content/plugins
		cp -R /srv/www/regno/mu-plugins /srv/www/wordpress-default/wp-content/
		echo "Copy themes"
		cp -R /srv/www/regno/themes/*  /srv/www/wordpress-default/wp-content/themes
	else
		echo "Updating regno plugins (only updating modified, delete /srv/www/regno on hos to overwrite)"
		cd /srv/www/regno 
		git pull --rebase origin master
		echo "Update plugins"
		cp -Ru /srv/www/regno/plugins/* /srv/www/wordpress-default/wp-content/plugins
		cp -Ru /srv/www/regno/mu-plugins /srv/www/wordpress-default/wp-content/
		echo "Update themes"
		cp -Ru /srv/www/regno/themes/* /srv/www/wordpress-default/wp-content/themes
	fi
	
fi
