###
	Grunt build system
###
module.exports = (grunt) ->

	config =
		pkg: grunt.file.readJSON 'package.json'
		watch:
			stylus:
				files: ['css/*.styl']
				tasks: ['stylus','cssmin']
				#tasks: ['stylus','cssmin','sftp-deploy']
			coffee:
				files: ['js/app.coffee']
				tasks: ['concat','uglify']
				#tasks: ['concat','uglify','sftp-deploy']
				# options:
				# # Start another live reload server on port 1337
				# 	livereload: 1337
		stylus:
			compile:
   			 	files:
   			 		'css/structure.dev.css' : 'css/structure.styl'
					# 'css/admin.css' : 'css/admin.styl'
		csslint: 
			lax: 
				options: 
					import: false
				src: ['css/*.css']

		cssmin:
			dist: 
				# src: [ 'css/utility/normalize.css',
				# 'css/utility/boxmodel.css',
				# 'css/structure.dev.css'
				# ]
				src: ['css/structure.dev.css']
				dest: 'css/sstructure.css'
				
		concat:
			dist:
				dest: 'js/app.development.js'
				src: [
					"js/vendor/custom.modernizr.js"
					"js/vendor/jquery-2.0.3.min.js"
					"js/app.js"
					]
		uglify:
			build:
				src: 'js/app.development.js'
				dest: 'js/app.build.js'

		'sftp-deploy': 
			build: 
				auth: 
					host: '162.243.51.134'
					port: 22
					authKey: 'key1' # Need hidden file .ftppass for this
				src: '.' # Root Folder
				dest: '/home/wordpress/public_html/wp-content/themes/starkers-master'
				exclusions: ['./**/.DS_Store',
				'./LICENSE.txt',
				'./README.txt',
				'./404.php',
				'./archive.php',
				'./author.php',
				'./category.php',
				'./comments.php',
				'./archive.php',
				'./page.php',
				'./search.php',
				'./single.php',
				'./style.css',
				'./tag.php',
				'./screenshot.png',
				'./index*',
				'./npm*',
				'./external',
				'./img',
				# './parts',
				'./css/utility',
				'./css/easing.styl',
				'./css/easing.css',
				'./css/methods.styl',
				'./css/methods.css',
				'./js/vendor',
				'./js/polyfill',
				'./Gruntfile.js',
				'./Gruntfile.coffee',
				'./package.json',
				'./.git*',
				'./node_modules', 
				'./.ftppass', 
				'./ftppass.json']
				server_sep: '/'
		
		
	grunt.initConfig config

	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-stylus'
	grunt.loadNpmTasks 'grunt-contrib-cssmin'
	grunt.loadNpmTasks 'grunt-contrib-csslint'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-sftp-deploy'
