package tonyt;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.Test;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;

import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;

// # auto-format shortcut: Shift+Option+F

public class ParallelTestRunner {

    @Test
    void testParallel() {
        // you can run a specific feature file
        // Runner.path("classpath:tonyt/j_profile.feature").tags("~@ignore") to speed up your test
        
        // Run clean up job first to prevent process deadlock-https://stackoverflow.com/questions/60943891/dynamic-scenario-freezes-when-called-using-afterfeature-hook/60944060#60944060
        Results cleanup = Runner.path("classpath:postrun/j_cleanup.feature").tags("~@ignore")
                .outputCucumberJson(false)
                .parallel(1);
        
        Results results = Runner.path("classpath:tonyt").tags("~@ignore")
                .outputCucumberJson(true)
                .parallel(2);
        generateReport(results.getReportDir());
        System.out.print("report dir=>" + results.getReportDir());
       
    }

    public static void generateReport(String karateOutputPath) {
        Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[] { "json" }, true);
        List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
        for (int i = 0; i < jsonPaths.size(); i++) {
            System.out.println("json path=>" + jsonPaths.get(i));
        }
        jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));

        Configuration config = new Configuration(new File("target"), "jaimee");

        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }

}