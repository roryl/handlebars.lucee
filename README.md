# Handlebars.lucee
An implementation of the Handlebars.js templating language in Lucee. Handlebars is a logic-less templating language and implements the language as defined by [Handlebars.js](http://handlebarsjs.com/)

This documentation will not go into specifics of the Handlebars syntax, for that see [Handlebars.js](http://handlebarsjs.com/)

Handlebars.lucee is a thin wrapper around [Handlebars.java](https://github.com/jknack/handlebars.java). For advanced usage and difference between Javascript Handlebars.js and Handlebars.lucee, read [their documentation](https://github.com/jknack/handlebars.java)

##Why Handlebars.lucee?
###Less Complex Templates
Handlebars is a logic-less templaing philosophy meaning that it does not by default contain expressions. It will only evaluate booleans and provide looping mechanisms. This keeps business logic from sneaking into view templates, but therefore requires that data passed to the template contains all of the output needed for rendering. It improves the separation and strictness of the view layer, at cost of the loss of templating flexibility. 

###Isomorphic Templates
By using Handlebars.lucee, an application can render output on the server using the same tempating library as in Javascript. This allows for quickly rendering on the server initial page loads, and then updating fragments from AJAX on the client.

###Easier for Designers
Because Handlebars templates don't contain any Lucee tags or functions, a designer doesn't need to know anything about Lucee to read the templates. The basic boolean logic is simply enough for anyone to understand.

##Usage
This documentationa assumes you are familiar with Handlebars or Mustache style templates and will not go into all of the uses. We recommend learning [Handlebars.js](http://handlebarsjs.com/) 

There are three methods to use Handlebars.lucee

1. Compiling Inline Templates
2. Compiling Template Files
3. Lucee Custom Tag

###Compiling Inline Templates
The following example will output a hello world:
```coldfusion
<cfscript>
myTemplate = new Handlebars().compileInLine("Hello {{this}}!");
echo(myTemplate("world")); //outputs Hello world!
</cfscript>
```

The compileInLine function takes a text string that is a valid handlebars template and returns a Closure in which the compiled template can be used. Handlebars.lucee follows the Handlebars.js convention in that compiling a template creates a function which can be further called. This means that you only need to compile once for all invocations of that template in the request, and you could even cache the compilation result. 

This example below compiles once, but outputs three different words
```coldfusion
<cfscript>
myTemplate = new Handlebars().compileInLine("Hello {{this}}!");
echo(myTemplate("world")); //outputs Hello world!
echo(myTemplate("Jim")); //outputs Hello Jim!
echo(myTemplate("there")); //outputs Hello there!
</cfscript>
```

###Compiling Template Files
Handlebars.lucee can read template files and compile them. Consider this template

helloworld.hbs
```handlebars
Hello {{this}}!
```

Then by passing the fully qualified path to the template to handlebars compile() function, it acheives the same result as compileInLine()

```coldfusion
<cfscript>
myTemplate = new Handlebars().compile(expandPath("helloworld.hbs"));
echo(myTemplate("world")); //outputs Hello world!
echo(myTemplate("Jim")); //outputs Hello Jim!
echo(myTemplate("there")); //outputs Hello there!
</cfscript>
```

In the current implementation of Handlebars.lucee, you must provide the full path to the file, relative paths are not allowed

###Lucee Custom Tag
The Handlebars.cfc file shipped with this repository is also a Lucee custom tag. Drop Handlebars.cfc into a customtag path to use it. With this usage method, the template file is put into the tag body. The data for the output is passed via the context argument, and it can be a string, array or struct.

myTemplate.cfm
```coldfusion
<cf_handlebars context="world">
Hello {{this}}!
</cf_handlebars>
```

Use this method for replacing Lucee .cfm templates with handlebar templates and not interferring with any existing view framework that may be in use.


##Requirements
* Built for and tested with Lucee 4.5+
* Requires the presence of rhino-1.7R4.jar on the *Servlet Container class path*. Because of the way the underlying Handlebars.java class instantiates Rhino, Lucee cannot dynamically load this jar, and it cannot be in the Railo Server or Web Contexts.

##Automatic Installation
The first time you instantiate the Handlebars.cfc, it will try to install the Rhino jar files and will throw an error prompting you to restart your Lucee instance to continue. This only needs to be done once.

###Supported Servlet Containers
The automatic installation has only been tested with the following Lucee installations
* via CommandBox on Windows
* via Lucee Tomcat Linux distribution

If you cannot get the automatic installation to work or you do not have one of the above installations, try the manual method below

###Example for calling the automatic installation
```coldfusion
//With throw installed and needs restart, or was failed
Handlebars = new Handlebars();
```

To troubleshoot issues with the installation, do not call the constructor, and then the install methods can be tried:

```coldfusion
Handlebars = createObject("handlebars");
writeDump(Handlebars.isInstalled()); //returns true or false if it can fine Rhino
Handlebars.install(); //attemptes the installation
```

##Manual Installation
If Handlebars.lucee cannot finish the installation, copy the file java/rhino-1.7R4.jar from this repository to the servlet container jar library. The other Java files do not need to be copied, they are loaded dynamically by Lucee
