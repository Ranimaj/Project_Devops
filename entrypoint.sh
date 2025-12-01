#!/bin/sh

# ============================================
# ENTRYPOINT pour Student Management Application
# ============================================

echo "========================================"
echo "🚀 Student Management Application"
echo "========================================"

# Afficher les informations système
echo "📦 Version: 0.0.1-SNAPSHOT"
echo "📅 Date: $(date)"
echo "🖥️  Host: $(hostname)"

# Vérifier la version Java
JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d '"' -f2)
echo "☕ Java Version: $JAVA_VERSION"

# Afficher la mémoire disponible
MEM_INFO=$(free -h 2>/dev/null | grep Mem || echo "Non disponible")
echo "💾 Mémoire: $MEM_INFO"

echo "🌐 Port d'écoute: 8089"
echo "📁 Répertoire de travail: $(pwd)"
echo "========================================"

# ============================================
# VÉRIFICATIONS PRÉLIMINAIRES
# ============================================

# Vérifier si le JAR existe
if [ ! -f /app/app.jar ]; then
    echo "❌ ERREUR CRITIQUE: Fichier app.jar introuvable!"
    echo ""
    echo "📁 Contenu du répertoire /app:"
    ls -la /app/
    echo ""
    echo "🔍 Recherche de fichiers JAR:"
    find /app -name "*.jar" 2>/dev/null || echo "Aucun fichier JAR trouvé"
    echo ""
    exit 1
fi

# Vérifier la taille du JAR
JAR_SIZE=$(ls -lh /app/app.jar | awk '{print $5}')
echo "📊 Taille du JAR: $JAR_SIZE"

# Vérifier que Java peut lire le JAR
echo "🔍 Vérification du JAR..."
java -jar /app/app.jar --version 2>/dev/null && \
    echo "✅ JAR vérifié avec succès" || \
    echo "⚠️  Le JAR ne contient pas de paramètre --version"

# ============================================
# DÉMARRAGE DE L'APPLICATION
# ============================================

echo ""
echo "========================================"
echo "⚡ Démarrage de l'application..."
echo "========================================"
echo ""

# Afficher les variables d'environnement pertinentes
echo "⚙️  Variables d'environnement:"
env | grep -E "(JAVA|SPRING|SERVER|PORT)" | sort || echo "Aucune variable spécifique trouvée"

echo ""
echo "🔄 Lancement de la commande: java -jar /app/app.jar"
echo ""

# Démarrer l'application
# Utilisation de exec pour que l'application reçoive les signaux système
exec java -jar /app/app.jar
