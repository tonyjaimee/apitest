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
/**
 *
 * @author pthomas3
 */
public class ParallelTestRunner {

    @Test
    void testParallel() {
        Results results = Runner.path("classpath:tonyt").tags("~@ignore")
                .outputCucumberJson(true)
                .parallel(5);
        generateReport(results.getReportDir());
        System.out.print("report dir=>" + results.getReportDir());
        // assertTrue(results.getFailCount() == 0, results.getErrorMessages());
        Results cleanup = Runner.path("classpath:postrun").tags("~@ignore")
                .outputCucumberJson(false)
                .parallel(1);
    }

    public static void generateReport(String karateOutputPath) {
        Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[] { "json" }, true);
        List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
        for (int i = 0; i < jsonPaths.size(); i++) {
            System.out.println("json path=>" + jsonPaths.get(i));
        }
        jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
        
        // when you change projectName param, you must execute mvn - clean to remove all files under target, else your report will not show up
        Configuration config = new Configuration(new File("target"), "jaimee");
        
        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }

}