#!/bin/bash

# Project name and directory setup
PROJECT_NAME="MyRestApiApp"
mkdir -p "$PROJECT_NAME/src/main/java/com/example"
mkdir -p "$PROJECT_NAME/src/main/webapp/WEB-INF"

# Create pom.xml
cat <<EOL > "$PROJECT_NAME/pom.xml"
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>$PROJECT_NAME</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.jboss.resteasy</groupId>
            <artifactId>resteasy-jaxrs</artifactId>
            <version>3.9.3.Final</version>
            <scope>provided</scope>
        </dependency>
    </dependencies>

    <build>
        <finalName>$PROJECT_NAME</finalName>
    </build>
</project>
EOL

# Create web.xml
cat <<EOL > "$PROJECT_NAME/src/main/webapp/WEB-INF/web.xml"
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
    <display-name>My REST API Application</display-name>

    <servlet>
        <servlet-name>javax.ws.rs.core.Application</servlet-name>
        <servlet-class>org.jboss.resteasy.plugins.server.servlet.HttpServletDispatcher</servlet-class>
        <init-param>
            <param-name>javax.ws.rs.Application</param-name>
            <param-value>com.example.MyApplication</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>

    <servlet-mapping>
        <servlet-name>javax.ws.rs.core.Application</servlet-name>
        <url-pattern>/api/*</url-pattern>
    </servlet-mapping>
</web-app>
EOL

# Create MyApplication.java
cat <<EOL > "$PROJECT_NAME/src/main/java/com/example/MyApplication.java"
package com.example;

import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;

@ApplicationPath("/api")
public class MyApplication extends Application {}
EOL

# Create HelloWorldResource.java
cat <<EOL > "$PROJECT_NAME/src/main/java/com/example/HelloWorldResource.java"
package com.example;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

@Path("/hello")
public class HelloWorldResource {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String sayHello() {
        return "Hello, World!";
    }
}
EOL

# Build the project
cd "$PROJECT_NAME" && mvn clean package
