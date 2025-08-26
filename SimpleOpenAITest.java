import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

public class SimpleOpenAITest {
    public static void main(String[] args) {
        String apiKey = "sk-OO7p1CfMcRawUDr1t-kNDpLaQPEhdM_1vDBqoQRc5VT3BlbkFJHkjyAytcqU3GvHIqYWBILYVfc5nWo3_XkHvSZ1iT4A";
        String apiUrl = "https://api.openai.com/v1/chat/completions";
        
        try {
            URL url = new URL(apiUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            
            // Set request method and headers
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/json");
            connection.setRequestProperty("Authorization", "Bearer " + apiKey);
            connection.setDoOutput(true);
            
            // Request body
            String requestBody = """
                {
                    "model": "gpt-3.5-turbo",
                    "messages": [{"role": "user", "content": "你好"}],
                    "max_tokens": 100
                }
                """;
            
            // Send request
            try (OutputStream os = connection.getOutputStream()) {
                byte[] input = requestBody.getBytes("utf-8");
                os.write(input, 0, input.length);
            }
            
            // Read response
            int responseCode = connection.getResponseCode();
            System.out.println("Response Code: " + responseCode);
            
            InputStream inputStream = responseCode >= 200 && responseCode < 300 
                ? connection.getInputStream() 
                : connection.getErrorStream();
                
            try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream, "utf-8"))) {
                StringBuilder response = new StringBuilder();
                String responseLine;
                while ((responseLine = br.readLine()) != null) {
                    response.append(responseLine.trim());
                }
                System.out.println("Response: " + response.toString());
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
