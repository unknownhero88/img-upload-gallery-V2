package com.example;

import org.apache.catalina.Context;
import org.apache.catalina.LifecycleException;
import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class Main {

    public static void main(String[] args) throws LifecycleException, IOException {

        // --- 1️⃣ Port Configuration ---
        String port = System.getenv("PORT");
        if (port == null || port.isEmpty()) {
            port = "10000"; // default for local
        }

        System.out.println("==> Starting Tomcat on port: " + port);

        // --- 2️⃣ Setup Tomcat ---
        Tomcat tomcat = new Tomcat();
        tomcat.setPort(Integer.parseInt(port));
        tomcat.setBaseDir(createTempDir());
        tomcat.getConnector(); // triggers connector creation

        // --- 3️⃣ Define Webapp Path ---
        String baseDir = System.getProperty("user.dir");
        String webappDir = baseDir + "/src/main/webapp";
        File webAppDirectory = new File(webappDir);
        if (!webAppDirectory.exists()) {
            throw new IllegalStateException("❌ Webapp folder not found at: " + webappDir);
        }
        System.out.println("==> Webapp directory: " + webAppDirectory.getAbsolutePath());

        Context ctx = tomcat.addWebapp("", webAppDirectory.getAbsolutePath());

        // --- 4️⃣ Tell Tomcat where compiled classes live ---
        File classesDir = new File(baseDir + "/target/classes");
        if (!classesDir.exists()) {
            throw new IllegalStateException("❌ Compiled classes not found at: " + classesDir.getAbsolutePath() +
                    "\n➡️ Run `mvn clean package` first.");
        }

        WebResourceRoot resources = new StandardRoot(ctx);
        resources.addPreResources(
                new DirResourceSet(resources, "/WEB-INF/classes", classesDir.getAbsolutePath(), "/")
        );
        ctx.setResources(resources);

        System.out.println("==> Classes loaded from: " + classesDir.getAbsolutePath());
        System.out.println("==> Tomcat configured successfully!");

        // --- 5️⃣ Start Server ---
        tomcat.start();
        System.out.println("🚀 Server running at: http://localhost:" + port);
        tomcat.getServer().await();
    }

    private static String createTempDir() {
        try {
            Path tempDir = Files.createTempDirectory("tomcat");
            tempDir.toFile().deleteOnExit();
            return tempDir.toString();
        } catch (IOException e) {
            throw new RuntimeException("Unable to create temp directory", e);
        }
    }
}
