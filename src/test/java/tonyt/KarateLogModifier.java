
package tonyt;

import com.intuit.karate.http.HttpLogModifier;

/**
 *
 * @author pthomas3, edited by Tony Thongsinthop
 */
public class KarateLogModifier implements HttpLogModifier {
    
    public static final HttpLogModifier INSTANCE = new KarateLogModifier();

    @Override
    // rule to apply masking on certain api path. If set "return true;", the masking logic will be applied to all APIs.
    public boolean enableForUri(String uri) {
        return true;
    }

    @Override
    public String uri(String uri) {
        return uri;
    }        

    @Override
    //mask header data
    public String header(String header, String value) {
        if (header.toLowerCase().contains("xss-protection") || header.toLowerCase().contains("authorization")) {
            return "***";
        }
        return value;
    }

    @Override
    //mask request body data
    public String request(String uri, String request) {
       
        if (request.toLowerCase().contains("email") 
        || request.toLowerCase().contains("password")) {
            return "***";
        }
        return request;
    }

    @Override
    //mask response body data
    public String response(String uri, String response) {
        // you can use a regex and find and replace if needed. "return ***" means the logic will mask the entire response body
        if (response.toLowerCase().contains("email") 
        || response.toLowerCase().contains("idToken")
        || response.toLowerCase().contains("refreshToken"))
        {
            return "***";
        }
        return response;
    }

}