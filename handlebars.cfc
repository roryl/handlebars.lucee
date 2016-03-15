/**
*
* @author Rory Laitila
* @description Handlebars.lucee implements the Handlebars.js templating language via the Handlebars.java library.
* this is a wrapper around the Handlebars.java library. See https://github.com/jknack/handlebars.java for advanced usages
*
*/

component output="false" displayname="" accessors="true"  {

	property name="useCache" default="true";
	property name="cacheKey" default="handlebars.lucee";
	property name="helperPath" default="helpers";

	public Handlebars function init(){

		var config = deserializeJson(fileRead("config.json"));
		variables.useCache = config.useCache;
		variables.cacheKey = config.cacheKey;
		variables.helperPath = config.helperPath;

		if(!isInstalled()){
			install();
			throw("Handlebars.lucee has been installed, you must restart Lucee for this to take effect");
		}
		return this;
	}


	/**************************************************************
	 * USER PUBLIC METHODS
	 *
	 * The following methods are used for instantiation of Handlebars templates
	 *
	 * compileInLine - Compiles a handlebars template string
	 * compile - compiles a file
	 * 
	 ***************************************************************/
 	public string function compileInLine(required string template){
 		var template = getJava().compileInLine(arguments.template);
 		var result = function(context){
 			var result = template.apply(arguments.context);
 			return result;
 		}
 		return result;
 	}

 	public closure function compile(required string templatePath){

 		var templatePath = arguments.templatePath;
 		if(!fileExists(templatePath)){
 			throw("Could not locate the template at the path #templatePath#");
 		}

 		var templateSource = fileRead(arguments.templatePath);
 		var template = compileInLine(templateSource); 		
 		return template;
 	}

 	public object function getJava(){

		if(handlebarsIsCached()){
			return cacheGetHandlebars();
		} else {
			return newHandlebars();
		}		
	}

 	/****************************************************************
 	 * SETUP AND CONTROL METHODS
 	 ****************************************************************/

	public boolean function isInstalled(){

		if(fileExists(getRhinoServletPath())){
			return true;
		} else {
			return false;
		}		
	}

	public void function install(){		
		try {
			var servletPath = getServletContainerPath() & "/rhino-1.7R4.jar";
			var rhinoPath = expandPath("java/rhino-1.7R4.jar");
			fileCopy(rhinoPath, servletPath);			
		} catch (any e){
			throw("Error installing Rhino library for Handlebars.lucee, the message was #e.message#");
			writeDump(e);
			abort;
		}
	}

	public void function cacheClear(){
		if(handlebarsIsCached()){
			structDelete(application, getCacheKey());
		}
	}	

	public boolean function handlebarsIsCached(){
		var result = structKeyExists(application, getCacheKey());
		return result;
	}

	/********************************************************************
	 * PRIVATE METHODS  
	 ********************************************************************/

	private string function getHelperPath(){
		return variables.helperPath;
	}

	private Object function cacheGetHandlebars(){
		if(handlebarsIsCached()){
			return application[getCacheKey()]
		} else {
			throw("Handlebars was not created, check that it exists in the cache before getting");
		}
	}

	private void function cacheHandlebars(required Object Handlebars){
		application[getCacheKey()] = arguments.handlebars;
	}
	

	private object function newHandlebars(){

		Handlebars = createObject('java','com.github.jknack.handlebars.Handlebars','java/handlebars-4.0.3.jar,java/commons-lang3-3.1.jar,java/antlr4-runtime-4.5.1-1.jar,java/rhino-1.7R4.jar').init();

		var helpers = directoryList(getHelperPath());
		for(helper in helpers){
			var jsFile = createObject("java", "java.io.File").init(helper);
			Handlebars.registerHelpers(jsFile);			
		}		

		if(getUseCache()){
			cacheHandlebars(Handlebars);
		}		

		return Handlebars;
	}

	private string function getServletContainerPath(){

		var path = expandPath("{lucee-server}");

		if(path CONTAINS ".commandbox"){
			//Server context is at something like C:\Users\Rory\.CommandBox\engine\cfml\server\lucee-server\context
			//We need to go 5 directories up to get to the path to copy the rhino jar
			path = expandPath(path & "../../../../../../lib");
		} else if (path CONTAINS "/opt/lucee"){
			path = "/opt/lucee/lib"; //Linux tomcat location
		} else {
			throw("Could not find a supported servlet container, try manually installing the Rhino rhino-1.7R4.jar as described in the documentation");
		}

		return path;

	}

	private string function getRhinoServletPath(){
		return getServletContainerPath() & "/rhino-1.7R4.jar";
	}


	/**********************************************************************
	 * CUSTOM TAG METHODS 
	 * onStartTag() and onEndTag are used when handlebars is invoked as a customtag
	 *********************************************************************/

	function onStartTag(){

	}

	function onEndTag(attributes, caller, generatedContent){

		template = this.compileInline(generatedContent);
		// var start = getTickCount();
		// writeDump(template.apply({name:"Rory"}));
		// writeDump(Handlebars);

		// echo(output);
		echo(template(attributes.context));
		// var end = getTickCount();
		// writeDump((end - start) / 1000);
		// abort;
	}
}
