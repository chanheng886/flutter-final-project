package com.example.backend.config;

import java.net.URI;
import javax.sql.DataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

@Configuration
public class DataSourceConfig {
    private static final Logger log = LoggerFactory.getLogger(DataSourceConfig.class);

    @Value("${spring.datasource.url:${SPRING_DATASOURCE_URL:${DATABASE_URL:}}}")
    private String rawUrl;

    @Value("${spring.datasource.username:${SPRING_DATASOURCE_USERNAME:}}")
    private String defaultUser;

    @Value("${spring.datasource.password:${SPRING_DATASOURCE_PASSWORD:}}")
    private String defaultPassword;

    @Bean
    @Primary
    public DataSource dataSource() {
        if (rawUrl == null || rawUrl.isBlank()) {
            throw new IllegalArgumentException(
                    "Database URL is not configured! Please provide SPRING_DATASOURCE_URL or DATABASE_URL.");
        }

        String jdbcUrl;
        String username = defaultUser;
        String password = defaultPassword;

        String trimmed = rawUrl.trim();
        if (trimmed.startsWith("jdbc:")) {
            jdbcUrl = trimmed;
        } else if (trimmed.startsWith("postgres://") || trimmed.startsWith("postgresql://")) {
            try {
                String dummy = trimmed.replaceFirst("^postgres(ql)?://", "http://");
                URI uri = URI.create(dummy);

                String host = uri.getHost();
                int port = uri.getPort() > 0 ? uri.getPort() : 5432;
                String path = (uri.getPath() != null && !uri.getPath().isEmpty()) ? uri.getPath() : "/postgres";

                if (uri.getUserInfo() != null && !uri.getUserInfo().isBlank()) {
                    String[] userPass = uri.getUserInfo().split(":", 2);
                    username = userPass[0];
                    if (userPass.length > 1) {
                        password = userPass[1];
                    }
                }

                String query = uri.getQuery() != null ? "?" + uri.getQuery() : "";
                jdbcUrl = "jdbc:postgresql://" + host + ":" + port + path + query;
                log.info("Converted postgres URI to JDBC URL: jdbc:postgresql://{}:{}{}", host, port, path);
            } catch (Exception e) {
                log.warn("Failed to parse postgres URI as standard URI, falling back to prefixing jdbc: {}", e.getMessage());
                jdbcUrl = "jdbc:" + trimmed;
            }
        } else {
            jdbcUrl = "jdbc:" + trimmed;
        }

        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(jdbcUrl);
        if (username != null && !username.isBlank()) {
            config.setUsername(username);
        }
        if (password != null && !password.isBlank()) {
            config.setPassword(password);
        }
        config.setDriverClassName("org.postgresql.Driver");
        config.setConnectionTimeout(30000);
        config.setMaximumPoolSize(5);
        config.setMinimumIdle(1);
        config.setIdleTimeout(300000);
        config.setMaxLifetime(900000);

        return new HikariDataSource(config);
    }
}
