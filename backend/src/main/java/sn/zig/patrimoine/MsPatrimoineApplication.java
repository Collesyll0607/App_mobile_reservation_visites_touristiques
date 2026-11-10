package sn.zig.patrimoine;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Point d'entrée du Microservice REST ms-patrimoine (TP1 - Dr Lamine FATY).
 * Expose les endpoints REST sur http://localhost:8081/api/patrimoines
 */
@SpringBootApplication
public class MsPatrimoineApplication {

    public static void main(String[] args) {
        SpringApplication.run(MsPatrimoineApplication.class, args);
        System.out.println("==================================================================");
        System.out.println("  MICROSERVICE MS-PATRIMOINE DEMARRE !                            ");
        System.out.println("  API REST : http://localhost:8081/api/patrimoines                ");
        System.out.println("  Console H2 : http://localhost:8081/h2-console                   ");
        System.out.println("  Actuator Health : http://localhost:8081/actuator/health         ");
        System.out.println("==================================================================");
    }
}
