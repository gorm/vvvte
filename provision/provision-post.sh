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

	# First tried to symlink in, but it was causing trouble with plugins that
	# relay on correct basename. PHP gets confused when you basename a symlink,
	# and return wrong path.
	if [ ! -e /srv/www/wordpress-multisite/wp-content/.was-provisioned ]
	then
		echo "Delete wordpress-multisite {plugins,mu-plugins,themes} directory"
		rm -rf /srv/www/wordpress-multisite/wp-content/{plugins,mu-plugins,themes}
		# only works on never version of git (after 2012)
		cd /srv/www/wordpress-multisite/wp-content
		git init .
		git remote add -f origin https://github.com/blgrgjno/main-blog-network.git
		git config core.sparsecheckout true
		echo plugins/ >> .git/info/sparse-checkout
		echo mu-plugins/ >> .git/info/sparse-checkout
		echo themes/ >> .git/info/sparse-checkout
		git pull origin master
		touch /srv/www/wordpress-multisite/wp-content/.was-provisioned
	else
		echo "Updating wordpress-multisite plugins"
		cd /srv/www/wordpress-multisite/wp-content
		git pull origin master
	fi
fi
