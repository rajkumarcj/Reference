import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.security.KeyStore;
import java.security.cert.CertificateFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;

public class Main {
    public static void main(String[] args) throws Exception {
        // Your CA certificate in text format
        String caCertText = "-----BEGIN CERTIFICATE-----\n" +
                    ***
                "-----END CERTIFICATE-----\n";

        // Load the CA certificate directly into a KeyStore
        KeyStore keyStore = KeyStore.getInstance(KeyStore.getDefaultType());
        keyStore.load(null, null);
        CertificateFactory cf = CertificateFactory.getInstance("X.509");
        keyStore.setCertificateEntry("caCert", cf.generateCertificate(new ByteArrayInputStream(caCertText.getBytes(StandardCharsets.UTF_8))));

        // Create a TrustManagerFactory with the KeyStore
        TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        tmf.init(keyStore);

        // Create an SSL context with the TrustManager
        SSLContext sslContext = SSLContext.getInstance("TLS");
        sslContext.init(null, tmf.getTrustManagers(), null);

        // Use the SSLContext with HttpClient
        HttpClient client = HttpClient.newBuilder()
                .sslContext(sslContext)
                .build();

        // Now you can use the HttpClient with the custom SSLContext
        // Example request:
        // HttpRequest request = HttpRequest.newBuilder()
        //         .uri(new URI("https://example.com"))
        //         .GET()
        //         .build();
        // HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        // System.out.println(response.body());
    }
}
