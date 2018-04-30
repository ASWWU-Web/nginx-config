server {
	listen 80;
	server_name aswwu.com www.aswwu.com collegian.aswwu.com;
	return 301 https://aswwu.com$request_uri;
}

server {
	listen 443 ssl;

	ssl on;
	# ssl_certificate         /etc/nginx/ssl/rapidssl_certificate.crt;
	# ssl_certificate_key	/etc/nginx/ssl/rapidssl_server.key;
	ssl_certificate		/etc/letsencrypt/live/aswwu.com-0001/fullchain.pem;
	ssl_certificate_key	/etc/letsencrypt/live/aswwu.com-0001/privkey.pem;

	root /var/www/html;
	index index.php index.html;
	server_name aswwu.com www.aswwu.com collegian.aswwu.com;

	location / {
		alias	/var/www/html/aswwu.com/live/;
		#rewrite ^/(.*) /#/$1;
		include	php.fast.conf;
	}

	location /dev {
		alias	/var/www/html/aswwu.com/dev;
	}

	location /staging {
  	alias /var/www/html/aswwu.com/staging;
  }

	location /server/ {
		proxy_pass_header Server;
		proxy_set_header Host $http_host;
		proxy_redirect off;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Scheme $scheme;
		proxy_pass http://python_backends/;
		#alias	/data/php_server;
		#include	php.fast.conf;
	}

	location /python_server/ {
		proxy_pass_header Server;
		proxy_set_header Host $http_host;
		proxy_redirect off;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Scheme $scheme;
		proxy_pass	http://python_backends/;
	}

  location /fonts {
    alias   /var/www/html/fonts;
    include php.fast.conf;
  }

  location /forms {
    alias   /var/www/html/forms;
    include php.fast.conf;
  }

	location /media/img {
		rewrite ^/media/img-xs/([A-Za-z0-9/_\s%-\.]+) /media/dynamicImages.php?max_width=50&imgfile=$1;
		rewrite ^/media/img-sm/([A-Za-z0-9/_\s%-\.]+) /media/dynamicImages.php?max_width=400&imgfile=$1;
		rewrite ^/media/img-md/([A-Za-z0-9/_\s%-\.]+) /media/dynamicImages.php?max_width=1024&imgfile=$1;
		rewrite ^/media/img-lg/([A-Za-z0-9/_\s%-\.]+) /media/dynamicImages.php?max_width=1920&imgfile=$1;
	}

	location /media {
    alias   /data/media;
    include php.fast.conf;
  }

  location /music {
    alias   /var/www/html/music;
    include php.fast.conf;
  }

  location /store {
    alias   /var/www/html/store;
    include php.fast.conf;
  }

  location /tobuildahome {
    alias   /var/www/html/tobuildahome;
    include php.fast.conf;
  }

	location /c_archives {
    alias   /data/collegian_archives/web;
		include php.fast.conf;
  }

	location /c_pdfs {
		alias	/data/collegian_archives;
	}



	location ~* ^/cosdllegian.* {
		proxy_set_header HOST $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_pass https://go.aswwu.com;
	}


# Simple pages.
	location /prayitforward {
		alias /var/www/html/prayitforward;
	}

	location /uploads {
		alias	/data/uploads;
	}

	location /railjam {
		alias	/var/www/html/railjam;
	}

	location /code {
		alias 	/var/www/html/code;
	}

	location /atlas {
		alias	/var/www/html/atlas;
	}

	location /thevoice {
		alias /var/www/html/the-voice;
	}


# entries are for single page apps.
	location /serviceday {
		alias	/var/www/html/service-day;
		try_files $uri $uri/ /serviceday/index.html;
	}

	location /jobs/app/ {
    alias /var/www/html/jobs/app/;
  }

  location /jobs {
    alias /var/www/html/jobs/dist/;
    try_files $uri $uri/ /jobs/index.html;
  }

	location /askanything/app/ {
		alias /var/www/html/ask-anything/app/;
	}

	location /askanything {
		alias /var/www/html/ask-anything/dist/;
		try_files $uri $uri/ /askanything/index.html;
	}

	location /mask/app/ {
		alias /var/www/html/mask/app/;
	}

	location /mask {
		alias /var/www/html/mask/dist/;
		try_files $uri $uri/ /mask/index.html;
	}


## These are a list of redirects.
	location /candidate {
		return 301 https://aswwu.com/uploads/ASWWU/Executive%20Declaration%20of%20Candidacy%202018.docx;
	}

	location ~ ^/(theVoice|TheVoice) {
		return 301 /thevoice;
	}

	location /thevoice/tickets {
		proxy_cache_valid 301 1d; # This may change soon so we'll put this.
    return 301 https://wwuform.formstack.com/forms/the_voice_of_walla_walla;
	}

	location /JOBS {
		proxy_cache_valid 301 7d; # This may change soon so we'll put this.
		return 301 /jobs;
	}

	location /collegian {
    return  301     /#/collegian;
  }

  location /social {
    proxy_cache_valid 301 1d;
    return 301      /#/departments/social;
  }

  location /globalservice {
    proxy_cache_valid 301 1d; # This may change soon so we'll put this.
    return 301 /#/departments/global_service/current_project;
  }

  location /photo {
    proxy_cache_valid 301 1d;
    return 301 https://aswwu.smugmug.com/browse;
  }

  location /video {
    proxy_cache_valid 301 1d;
    return 301 https://vimeo.com/aswwu;
  }


##This is for the ASWWU documentation.
	location /docs {
    alias /var/www/html/docs;
		location /docs {
  		try_files $uri $uri/ /index.html;
  		if (!-e $request_filename){ rewrite ^(.*)$ /docs/index.php last; }
		}
    include php.fast.conf;
		location ~* /(.git|cache|bin|logs|backups|tests)/.*$ { return 403; }
		location ~* /(system|vendor)/.*\.(txt|xml|md|html|yaml|php|pl|py|cgi|twig|sh|bat)$ { return 403; }
		location ~* /user/.*\.(txt|md|yaml|php|pl|py|cgi|twig|sh|bat)$ { return 403; }
		location ~ /(LICENSE.txt|composer.lock|composer.json|nginx.conf|web.config|htaccess.txt|\.htaccess) { return 403; }
    }
}
