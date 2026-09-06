import com.sun.net.httpserver.HttpServer;
import java.net.InetSocketAddress;

public class Main {
    public static void main(String[] args) throws Exception {

        HttpServer server = HttpServer.create(
            new InetSocketAddress(8080), 0
        );

        server.createContext("/", exchange -> {
            String response = "<h1>Hello World from Java</h1>";

            exchange.getResponseHeaders()
                   .set("Content-Type", "text/html");

            exchange.sendResponseHeaders(
                200, response.getBytes().length
            );

            exchange.getResponseBody()
                   .write(response.getBytes());

            exchange.close();
        });

        server.start();

        System.out.println("Server running on port 8080");
    }
}