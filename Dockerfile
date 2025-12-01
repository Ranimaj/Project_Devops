FROM alpine:latest AS builder

LABEL maintainer="devops-team@company.com"
LABEL version="1.0"
LABEL description="Student Management Application"

RUN echo "🔧 Installation des dépendances..." && \
    apk update && \
    apk add --no-cache \
        openjdk17 \
        curl \
        bash && \
    rm -rf /var/cache/apk/* && \
    echo "✅ Dépendances installées" && \
    java -version

WORKDIR /app

COPY target/*.jar app.jar

RUN echo "🔍 Vérification du build..." && \
    if [ ! -f app.jar ]; then \
        echo "❌ ERREUR: Fichier JAR manquant dans /app!" && \
        echo "📁 Contenu de /app:" && \
        ls -la /app/ && \
        exit 1; \
    fi && \
    echo "✅ JAR présent:" && \
    echo "   - Taille: $(ls -lh app.jar | awk '{print $5}')" && \
    echo "   - Date: $(ls -la app.jar | awk '{print $6, $7, $8}')" && \
    echo "📦 Contenu du JAR (premiers fichiers):" && \
    jar tf app.jar | head -10 && \
    echo "..."

COPY entrypoint.sh /entrypoint.sh

RUN echo "⚙️ Configuration du script d'entrée..." && \
    chmod +x /entrypoint.sh && \
    echo "✅ Permissions:" && \
    ls -la /entrypoint.sh && \
    echo "📄 Contenu du script:" && \
    head -20 /entrypoint.sh && \
    echo "..."

EXPOSE 8089

ENTRYPOINT ["/entrypoint.sh"]

VOLUME ["/app/logs"]

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8089/actuator/health || exit 1
