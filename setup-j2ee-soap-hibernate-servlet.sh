#!/bin/bash

# Define project directory
PROJECT_DIR="soap-hibernate-oracle-project"
GROUP_ID="com.example"
ARTIFACT_ID="soap-hibernate"
PACKAGE_NAME="com/example/soap"
ENTITY_PACKAGE="$PACKAGE_NAME/entity"
SERVICE_PACKAGE="$PACKAGE_NAME/service"

# Create project structure
echo "Creating Maven project structure..."

mkdir -p $PROJECT_DIR/src/main/java/$ENTITY_PACKAGE
mkdir -p $PROJECT_DIR/src/main/java/$SERVICE_PACKAGE
mkdir -p $PROJECT_DIR/src/main/resources
mkdir -p $PROJECT_DIR/src/main/webapp/WEB-INF

# Create POM file for the project (no Sun-specific libraries)
cat <<EOF > $PROJECT_DIR/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>$GROUP_ID</groupId>
    <artifactId>$ARTIFACT_ID</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>

    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <maven.version>3.9.6</maven.version>
    </properties>

    <dependencies>
        <!-- Java EE API (for JAX-WS, Servlets, etc.) -->
        <dependency>
            <groupId>javax</groupId>
            <artifactId>javaee-api</artifactId>
            <version>8.0</version>
            <scope>provided</scope>
        </dependency>

        <!-- Hibernate Core 5.2.18 (compatible with Java 11) -->
        <dependency>
            <groupId>org.hibernate</groupId>
            <artifactId>hibernate-core</artifactId>
            <version>5.2.18.Final</version>
        </dependency>

        <!-- Oracle JDBC Driver -->
        <dependency>
            <groupId>com.oracle.database.jdbc</groupId>
            <artifactId>ojdbc8</artifactId>
            <version>19.8.0.0</version>
        </dependency>

        <!-- JPA API -->
        <dependency>
            <groupId>javax.persistence</groupId>
            <artifactId>javax.persistence-api</artifactId>
            <version>2.1</version>
        </dependency>

        <!-- Logging -->
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>1.7.25</version>
        </dependency>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-simple</artifactId>
            <version>1.7.25</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <!-- Maven Compiler Plugin for Java 11 -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>11</source>
                    <target>11</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# Create Hibernate configuration file (hibernate.cfg.xml)
cat <<EOF > $PROJECT_DIR/src/main/resources/hibernate.cfg.xml
<!DOCTYPE hibernate-configuration PUBLIC
        "-//Hibernate/Hibernate Configuration DTD 3.0//EN"
        "http://hibernate.sourceforge.net/hibernate-configuration-3.0.dtd">

<hibernate-configuration>
    <session-factory>
        <!-- Database connection settings -->
        <property name="hibernate.connection.driver_class">oracle.jdbc.OracleDriver</property>
        <property name="hibernate.connection.url">jdbc:oracle:thin:@localhost:1521:XE</property>
        <property name="hibernate.connection.username">your_oracle_username</property>
        <property name="hibernate.connection.password">your_oracle_password</property>

        <!-- Hibernate settings -->
        <property name="hibernate.dialect">org.hibernate.dialect.Oracle12cDialect</property>
        <property name="hibernate.hbm2ddl.auto">none</property>
        <property name="hibernate.show_sql">true</property>
    </session-factory>
</hibernate-configuration>
EOF

# Create Hibernate mapping file (MyEntity.hbm.xml)
cat <<EOF > $PROJECT_DIR/src/main/resources/MyEntity.hbm.xml
<?xml version="1.0"?>
<!DOCTYPE hibernate-mapping PUBLIC "-//Hibernate/Hibernate Mapping DTD 3.0//EN"
    "http://hibernate.sourceforge.net/hibernate-mapping-3.0.dtd">
<hibernate-mapping>
    <class name="com.example.soap.entity.MyEntity" table="DUAL">
        <id name="dummy" column="DUMMY">
            <generator class="assigned"/>
        </id>
    </class>
</hibernate-mapping>
EOF

# Create SOAP Web Service class (MyWebService.java) using only Java EE and Hibernate Criteria
cat <<EOF > $PROJECT_DIR/src/main/java/$SERVICE_PACKAGE/MyWebService.java
package com.example.soap.service;

import javax.jws.WebMethod;
import javax.jws.WebService;
import javax.ejb.Stateless;
import javax.servlet.annotation.WebServlet;
import javax.xml.ws.WebServiceProvider;
import com.example.soap.entity.MyEntity;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;
import org.hibernate.Criteria;
import org.hibernate.criterion.Restrictions;

@WebService
@Stateless
public class MyWebService {

    @WebMethod
    public String queryDual() {
        // Hibernate session and transaction
        Session session = new Configuration().configure().buildSessionFactory().openSession();
        Transaction transaction = null;
        String result = null;

        try {
            transaction = session.beginTransaction();

            // Use Hibernate Criteria API
            Criteria criteria = session.createCriteria(MyEntity.class);
            criteria.add(Restrictions.eq("dummy", "X"));  // DUAL table always has DUMMY = 'X'
            MyEntity entity = (MyEntity) criteria.uniqueResult();

            if (entity != null) {
                result = "Result from DUAL: " + entity.getDummy();
            } else {
                result = "No result found.";
            }

            transaction.commit();
        } catch (Exception e) {
            if (transaction != null) {
                transaction.rollback();
            }
            e.printStackTrace();
            result = "Error during database query.";
        } finally {
            session.close();
        }
        return result;
    }
}
EOF

# Create MyEntity class (MyEntity.java)
cat <<EOF > $PROJECT_DIR/src/main/java/$ENTITY_PACKAGE/MyEntity.java
package com.example.soap.entity;

public class MyEntity {
    private String dummy;

    public String getDummy() {
        return dummy;
    }

    public void setDummy(String dummy) {
        this.dummy = dummy;
    }
}
EOF

# Create web.xml (for servlet configuration using standard JAX-WS)
cat <<EOF > $PROJECT_DIR/src/main/webapp/WEB-INF/web.xml
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
         http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">

    <servlet>
        <servlet-name>jaxws-servlet</servlet-name>
        <servlet-class>javax.xml.ws.spi.http.HttpHandler</servlet-class>
    </servlet>

    <servlet-mapping>
        <servlet-name>jaxws-servlet</servlet-name>
        <url-pattern>/MyWebService</url-pattern>
    </servlet-mapping>

</web-app>
EOF

# Notify user
echo "Compact Maven SOAP Web Service project using Java EE Servlets created successfully in $PROJECT_DIR."
echo "Next steps:"
echo "1. Navigate to $PROJECT_DIR and run 'mvn clean install' to build the project."
echo "2. Configure your Oracle database connection details in 'hibernate.cfg.xml'."
echo "3. Deploy the WAR to your server (e.g., JBoss, WildFly)."
