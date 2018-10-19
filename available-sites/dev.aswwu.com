server {
  listen 	80;
  server_name	dev.aswwu.com;
  return 	301 https://dev.aswwu.com$request_uri;
}

server {
  listen 443 ssl;

  ssl 			on;
  ssl_certificate	/etc/letsencrypt/live/dev.aswwu.com/fullchain.pem;
  ssl_certificate_key	/etc/letsencrypt/live/dev.aswwu.com/privkey.pem;

  root		/var/www/html;
  index 	index.php index.html;
  server_name	dev.aswwu.com;

  location / {
    root	/var/www/html/homepage/dev;
    try_files	$uri $uri/ /index.html;
  }
	
  location /server/ {
    proxy_pass_header	Server;
    proxy_set_header	Host $http_host;
    proxy_redirect	off;
    proxy_set_header	X-Real-IP $remote_addr;
    proxy_set_header	X-Scheme $scheme;
    proxy_pass		http://python_backends/;
  }

  location /python_server/ {
    proxy_pass_header	Server;
    proxy_set_header	Host $http_host;
    proxy_redirect	off;
    proxy_set_header	X-Real-IP $remote_addr;
    proxy_set_header	X-Scheme $scheme;
    proxy_pass		http://python_backends/;
  }

  location /fonts {
    alias	/var/www/html/fonts;
    include 	php.fast.conf;
  }

  location /forms {
    alias	/var/www/html/forms;
    include	php.fast.conf;
  }

  location /media/img {
    rewrite ^/media/img-xs/([A-Za-z0-9/_\s%-\.]+) /media/dynamicImages.php?max_width=50&imgfile=$1;
    rewrite ^/media/img-sm/([A-Za-z0-9/_\s%-\.]+) /media/dynamicImages.php?max_width=400&imgfile=$1;
    rewrite ^/media/img-md/([A-Za-z0-9/_\s%-\.]+) /media/dynamicImages.php?max_width=1024&imgfile=$1;
    rewrite ^/media/img-lg/([A-Za-z0-9/_\s%-\.]+) /media/dynamicImages.php?max_width=1920&imgfile=$1;
  }

  location /media {
    alias	/data/media;
    include	php.fast.conf;
  }

  location /music {
    alias	/var/www/html/music;
    include	php.fast.conf;
  }

  location /store {
    alias	/var/www/html/store;
    include	php.fast.conf;
  }

  location /tobuildahome {
    alias	/var/www/html/tobuildahome;
    include	php.fast.conf;
  }

  location /c_archives {
    alias	/data/collegian_archives/web;
    include	php.fast.conf;
  }

  location /c_pdfs {
    alias /data/collegian_archives;
  }

  location ~* ^/cosdllegian.* {
    proxy_set_header	HOST $host;
    proxy_set_header	X-Real-IP $remote_addr;
    proxy_set_header	X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header	X-Forwarded-Proto $scheme;
    proxy_pass		https://go.aswwu.com;
  }


# Simple pages.
  location /prayitforward {
    alias /var/www/html/prayitforward;
  }

  location /uploads {
    alias /data/uploads;
  }

  location /railjam {
    alias /var/www/html/railjam;
  }

  location /code {
    alias /var/www/html/code;
  }

  location /atlas {
    alias /var/www/html/atlas;
  }

  location /thevoice {
    alias /var/www/html/the-voice;
  }

  location /botc {
    alias /var/www/html/botc;
  }

  location /shaneandshane {
    alias /var/www/html/shane-and-shane;
  }

  location /recycle {
    alias /var/www/html/recycle;
  }
	
  location /recycling {
    return 301 /recycle;
  }

  # entries are for single page apps.
  location /serviceday {
    alias	/var/www/html/service-day;
    try_files	$uri $uri/ /serviceday/index.html;
  }

  location /jobs/app/ {
    alias /var/www/html/jobs/app/;
  }

  location /jobs {
    alias	/var/www/html/jobs/dist/;
    try_files	$uri $uri/ /jobs/index.html;
  }

  location /askanything/app/ {
    alias /var/www/html/ask-anything/app/;
  }

  location /askanything {
    alias	/var/www/html/ask-anything/dist/;
    try_files	$uri $uri/ /askanything/index.html;
  }

  location /mask {
    alias	/var/www/html/mask/;
    try_files	$uri $uri/ /mask/index.html;
  }
	
  location /pages {
    alias	/var/www/html/pages/;
    try_files	$uri $uri/ /pages/index.html;
  }

## These are a list of redirects.
	location /polls {
		return 302 https://wwuform.formstack.com/forms/district_3_vote;
	}

	location ~ ^/(treadshed|TreadShed) {
		proxy_cache_valid 301 1d;
		return 302 https://aswwu.com/pages/treadshed;
	}

	location /candidate {
		return 302 https://aswwu.com/uploads/ASWWU/Executive%20Declaration%20of%20Candidacy%202018.docx;
	}

	location ~ ^/(theVoice|TheVoice) {
		return 302 /thevoice;
	}

	location ~ ^/(botb|BOTB) {
		return 302 https://wwuform.formstack.com/forms/botb_tickets;
	}

	location ~ ^/(escaperoom|EscapeRoom) {
		return 302 https://docs.google.com/forms/d/e/1FAIpQLSdHZo2t2zFUSzN9TamiG9tSs-nztXlT4liwi-0ji44p8OaQxQ/viewform;
	}

	location ~ ^/(fitness|Fitness) {
		return 302 https://docs.google.com/forms/d/e/1FAIpQLScHGU9L3-LqOzk8IB9vHESEDVgYcfPH3s_f4t0gPqtvsK9PAQ/viewform;
	}

	location /vote {
		return 302 https://docs.google.com/forms/d/e/1FAIpQLScMV3hxpewwZBWvz6O2nc0grWdTwU8ZgZoNB89IFyeodoJhpQ/viewform?usp=sf_link; 
	}

	location /thevoice/tickets {
		proxy_cache_valid 302 1d; # This may change soon so we'll put this.
				return 301 https://wwuform.formstack.com/forms/the_voice_of_walla_walla;
	}

	location /botc/tickets {
		return 302 https://wwuform.formstack.com/forms/aswwu_battle_of_the_comedians;
	}

	location /JOBS {
		proxy_cache_valid 301 7d; # This may change soon so we'll put this.
		return 302 /jobs;
	}

	location /collegian {
		return  301     /pages/collegian;
	}

	location ~ ^/(banquet|Banquet|BANQUET) {
		return 302 https://wwuform.formstack.com/forms/spring_banquet;
	}

	location /social {
		proxy_cache_valid 301 1d;
		return 301      /pages/social;
	}

	location /globalservice {
		proxy_cache_valid 301 1d; # This may change soon so we'll put this.
		return 301 /pages/global_service;
	}

	location /photo {
		proxy_cache_valid 302 1d;
		return 302 /pages/photo;
	}

	location /video {
		proxy_cache_valid 302 1d;
		return 302 /pages/video;
	}
	
	location ~ ^/(sns|sas) {
		return 302 /shaneandshane;
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
