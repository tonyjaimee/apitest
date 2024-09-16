package tonyt;

// Java library
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Properties;

import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.Test;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;

import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.http.nio.netty.NettyNioAsyncHttpClient;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3AsyncClient;
import software.amazon.awssdk.transfer.s3.S3TransferManager;
import software.amazon.awssdk.transfer.s3.model.CompletedDirectoryUpload;
import software.amazon.awssdk.transfer.s3.model.DirectoryUpload;
import software.amazon.awssdk.transfer.s3.model.UploadDirectoryRequest;

// # auto-format shortcut: Shift+Option+F, screenshot: shift+command+3, reveal hidden file in Mac OS:  Shift + Control (command) + dot

public class ParallelTestRunner {

    // Testing variables
    private static String FEATURE_FILE_CLEANUP_LOCATION;
    private static String FEATURE_FILE_TEST_LOCATION;

    // S3 connection variables
    private static String S3_BUCKET_NAME;
    private static String S3_SOURCE_FOLDER;
    private static String S3_ACCESS_KEY;
    private static String S3_SECRET;

    // Contructor
    public ParallelTestRunner() {
        super();
    }

    // Main method
    @Test
    public void runTest() {
        setParameters();
        runParallelTest();
        uploadToS3();
    }

    private void setParameters() {
        try {
            Properties prop = new Properties();

            /*
             * To create .properties file
             * 1) Create "package" called src.test.resources (not folder)
             * 2) Add the file "config.properties"
             * 3) under POM.XML, you need to add below line to instruct Maven to copy your .properties file into the target directory.
             * Why? Because your code will try to find the .properties file at target folder (where you deploy)
             *  <testResource>
                    <directory>src/test/resources</directory>
                    <filtering>true</filtering>
                </testResource>
             */
            ClassLoader loader = Thread.currentThread().getContextClassLoader();
            InputStream stream = loader.getResourceAsStream("config.properties");

            if (stream == null) {
                System.out.println("Unable to find config.properties");
                return;
            }
            prop.load(stream);

            FEATURE_FILE_CLEANUP_LOCATION = prop.getProperty("featurefile.cleanup.location");
            FEATURE_FILE_TEST_LOCATION = prop.getProperty("featurefile.test.location");
            S3_BUCKET_NAME = prop.getProperty("s3.bucketname");
            S3_SOURCE_FOLDER = prop.getProperty("s3.sourcefolder");
            S3_ACCESS_KEY = prop.getProperty("s3.accesskey");
            S3_SECRET = prop.getProperty("s3.secret");
            
            //System.out.println(prop.getProperty("featurefile.cleanup.location"));
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }

    // Methods
    private void runParallelTest() {
        /*
         * You can run a specific feature file to speed up your test
         * / e.g., Runner.path("classpath:tonyt/j_profile.feature").tags("~@ignore")
         * 
         * / Run clean up job first to prevent process deadlock
         * / https://stackoverflow.com/questions/60943891/dynamic-scenario-freezes-when-
         * called-using-afterfeature-hook/60944060#60944060
         */

        Results cleanup = Runner.path(FEATURE_FILE_CLEANUP_LOCATION).tags("~@ignore")
                .outputCucumberJson(false)
                .parallel(1);

        Results results = Runner.path(FEATURE_FILE_TEST_LOCATION).tags("~@ignore")
                .outputCucumberJson(true)
                .parallel(1);
        generateReport(results.getReportDir());
        System.out.println("#####Report directory#####");
        System.out.println(results.getReportDir());
        
    }

    private void generateReport(String karateOutputPath) {
        Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[] { "json" }, true);
        List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
        jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
        Configuration config = new Configuration(new File("target"), "jaimee");
        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }

    public S3TransferManager createS3TransferManager() {

        AwsBasicCredentials awsCredentials = AwsBasicCredentials.create(
                S3_ACCESS_KEY,
                S3_SECRET);
        Region region = Region.AP_SOUTHEAST_2;
        S3AsyncClient s3AsyncClient = S3AsyncClient.builder()
                .credentialsProvider(StaticCredentialsProvider.create(awsCredentials))
                .region(region)
                .httpClientBuilder(NettyNioAsyncHttpClient.builder()
                        .maxConcurrency(10)
                        .maxPendingConnectionAcquires(1000))
                .build();
        S3TransferManager transferManager = S3TransferManager.builder()
                .s3Client(s3AsyncClient)
                .build();
        return transferManager;
    }

    private void uploadToS3() {
        try {

            /*File myFile = new File("test_folder/test.txt");
            myFile.getParentFile().mkdir();
            myFile.createNewFile();
            */
            System.out.println("#####S3 upload begin#####");
            S3TransferManager s3TransferManager = createS3TransferManager();
            DirectoryUpload directoryUpload = s3TransferManager.uploadDirectory(UploadDirectoryRequest.builder()
                    .source(Paths.get(S3_SOURCE_FOLDER))
                    .bucket(S3_BUCKET_NAME)
                    .build());
            System.out.println("#####S3 upload in progress#####");
            // Wait for the transfer to complete
            CompletedDirectoryUpload completedDirectoryUpload = directoryUpload.completionFuture().join();

            System.out.println("#####S3 upload completed#####");

            // Print out any failed uploads
            completedDirectoryUpload.failedTransfers().forEach(System.out::println);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}