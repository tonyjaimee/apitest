package tonyt;
import com.intuit.karate.junit5.Karate;
class SingleTestRunner {       
    //run the entire .feature file (testapi.feature)
    @Karate.Test
    Karate runApiAuth() {
        return Karate.run("j_api_authentication").relativeTo(getClass());
    }

    @Karate.Test
    Karate runApiProfile() {
        return Karate.run("j_profile").relativeTo(getClass());
    }

    //run a specific scenario on the .feature file that has a tag name "HelloWorld"
    //@Karate.Test
    //Karate runTestHelloWorld() {
    //    return Karate.run("airlines").tags("@GetAirlineById").relativeTo(getClass());
    //}
} 