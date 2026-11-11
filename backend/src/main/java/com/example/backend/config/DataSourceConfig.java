package com.example.backend.config;
import java.net.URI;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
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
            // Strip inline credentials (user:password@host) — JDBC driver rejects them
            String stripped = stripInlineCredentials(trimmed, username, password);
            if (stripped != null) {
                String[] parts = stripped.split(":", 3);
                if (parts.length >= 3) {
                    username = parts[0];
                    password = parts[1];
                    jdbcUrl = parts[2];
                } else {
                    jdbcUrl = stripped;
                }
            } else {
                jdbcUrl = trimmed;
            }
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

        jdbcUrl = stripUnsupportedParams(jdbcUrl);

        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(jdbcUrl);
        if (username != null && !username.isBlank()) {
            config.setUsername(username);
        }
        if (password != null && !password.isBlank()) {
            config.setPassword(password);
        }
        config.setDriverClassName("org.postgresql.Driver");
        config.setConnectionTimeout(60000);
        config.setMaximumPoolSize(5);
        config.setMinimumIdle(0);
        config.setIdleTimeout(300000);
        config.setMaxLifetime(600000);
        config.setLeakDetectionThreshold(120000);
        config.setValidationTimeout(30000);

        // Neon pooler sometimes drops connections during Hikari's fail-fast
        // check at bean construction time. Retry a few times before giving up
        // so a transient drop doesn't crash the application context.
        int maxAttempts = 5;
        int attempt = 0;
        while (true) {
            attempt++;
            try {
                return new HikariDataSource(config);
            } catch (Exception e) {
                if (attempt >= maxAttempts) {
                    log.error("Failed to create DataSource after {} attempts", attempt, e);
                    throw e;
                }
                log.warn("DataSource creation failed (attempt {}/{}): {} — retrying in 3s",
                        attempt, maxAttempts, e.getMessage());
                try {
                    Thread.sleep(3000);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    throw new IllegalStateException("Interrupted while retrying DataSource creation", ie);
                }
            }
        }
    }

    /**
     * Strips inline credentials from a jdbc:postgresql://user:password@host URL.
     * Returns "user:password:jdbc:postgresql://host..." or null if no inline creds found.
     */
    private String stripInlineCredentials(String url, String fallbackUser, String fallbackPassword) {
        Pattern p = Pattern.compile(
                "^(jdbc:postgresql://)([^:/@]+):([^@]+)@(.*)$",
                Pattern.CASE_INSENSITIVE);
        Matcher m = p.matcher(url);
        if (!m.matches()) {
            return null;
        }
        String prefix = m.group(1);
        String user = m.group(2);
        String pass = m.group(3);
        String rest = m.group(4);
        return user + ":" + pass + ":" + prefix + rest;
    }

    /**
     * Removes query params the PostgreSQL JDBC driver does not understand
     * (e.g. channel_binding). Keeps sslmode and standard params.
     */
    private String stripUnsupportedParams(String jdbcUrl) {
        if (!jdbcUrl.contains("?")) {
            return jdbcUrl;
        }
        int q = jdbcUrl.indexOf('?');
        String base = jdbcUrl.substring(0, q);
        String query = jdbcUrl.substring(q + 1);

        StringBuilder kept = new StringBuilder();
        for (String pair : query.split("&")) {
            String[] kv = pair.split("=", 2);
            String key = kv[0].toLowerCase();
            if (key.equals("channel_binding") || key.equals("ssloptions") || key.equals("sslcrldirs")) {
                continue;
            }
            if (kept.length() > 0) kept.append("&");
            kept.append(pair);
        }
        String result = base;
        if (kept.length() > 0) result += "?" + kept;
        if (!result.equals(jdbcUrl)) {
            log.info("Stripped unsupported JDBC params from URL");
        }
        return result;
    }
}