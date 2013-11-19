if [ -d /srv/www/wordpress-multisite ]
then
	cd /srv/www/wordpress-multisite 
	if ! egrep -q define.*\'MULTISITE\'.*true wp-config.php
	then
		echo "Transforming to multisite"
		wp core multisite-convert --title="My Network"
	else
		echo "Already multisite"
	fi

	if ! egrep -q define.*WPLANG.*nb_NO wp-config.php
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
		echo "Link in plugins"
		rm -rf /srv/www/wordpress-multisite/wp-content/plugins
		ln -s /srv/www/regno/plugins /srv/www/wordpress-multisite/wp-content/
		ln -s /srv/www/regno/mu-plugins /srv/www/wordpress-multisite/wp-content/
		echo "Link in themes"
		rm -rf /srv/www/wordpress-multisite/wp-content/themes
		ln -s /srv/www/regno/themes /srv/www/wordpress-multisite/wp-content/
	else
		echo "Updating regno plugins"
		cd /srv/www/regno 
		git pull --rebase origin master
	fi
fi
