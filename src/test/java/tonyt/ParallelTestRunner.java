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

/**
 *
 * @author pthomas3
 */
public class ParallelTestRunner {

    @Test
    void testParallel() {
        Results results = Runner.path("classpath:tonyt").tags("~@ignore")
                .outputCucumberJson(true)
                .parallel(10);
        generateReport(results.getReportDir());
        System.out.print("report dir=>" + results.getReportDir());
        //assertTrue(results.getFailCount() == 0, results.getErrorMessages());
        Results cleanuprun = Runner.path("classpath:postrun").tags("~@ignore")
                .outputCucumberJson(true)
                .parallel(10);
    }

    public static void generateReport(String karateOutputPath) {
        Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[] {"json"}, true);
        List<String> jsonPaths = new ArrayList<>(jsonFiles.size());
        jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
        Configuration config = new Configuration(new File("target"), "jaimee");
        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }

}