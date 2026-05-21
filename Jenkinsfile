pipeline {
    agent any
    
    environment {
        PROJECT_NAME = 'portfolio-website'
        CONTAINER_NAME = 'portfolio-website'
        IMAGE_NAME = 'portfolio:latest'
        PORT = '3000'
        DOCKER_BUILDKIT = '0'
        COMPOSE_DOCKER_CLI_BUILD = '0'
    }
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['deploy', 'stop', 'restart', 'status', 'logs'],
            description: 'What action to perform?'
        )
        booleanParam(
            name: 'CLEANUP_OLD',
            defaultValue: false,
            description: 'Clean up old containers and images?'
        )
        booleanParam(
            name: 'FORCE_REBUILD',
            defaultValue: false,
            description: 'Force rebuild Docker image?'
        )
    }
    
    stages {
        stage('Preparation') {
            steps {
                script {
                    echo "=== PORTFOLIO WEBSITE DEPLOYMENT ==="
                    echo "Action: ${params.ACTION}"
                    echo "Container: ${env.CONTAINER_NAME}"
                    echo "Port: http://localhost:${env.PORT}"
                    
                    // Change to project directory
                    dir('/var/projects/nothing-to-add.github.io') {
                        sh 'pwd && ls -la'
                    }
                }
            }
        }
        
        stage('Stop Existing') {
            when { 
                anyOf {
                    expression { params.ACTION == 'deploy' }
                    expression { params.ACTION == 'restart' }
                    expression { params.ACTION == 'stop' }
                }
            }
            steps {
                script {
                    dir('/var/projects/nothing-to-add.github.io') {
                        sh '''
                            echo "Stopping existing containers..."
                            docker compose down || true
                            
                            if [ "${CLEANUP_OLD}" = "true" ]; then
                                echo "Cleaning up old images..."
                                if docker image inspect ${IMAGE_NAME} > /dev/null 2>&1; then
                                    docker rmi ${IMAGE_NAME} || true
                                    echo "Old image removed."
                                else
                                    echo "No existing image to remove, skipping."
                                fi
                                docker system prune -f || true
                            fi
                        '''
                    }
                }
            }
        }
        
        stage('Build & Deploy') {
            when { 
                anyOf {
                    expression { params.ACTION == 'deploy' }
                    expression { params.ACTION == 'restart' }
                }
            }
            steps {
                script {
                    dir('/var/projects/nothing-to-add.github.io') {
                        sh '''
                            echo "Building and starting portfolio website..."
                            
                            if [ "${FORCE_REBUILD}" = "true" ]; then
                                echo "Force rebuilding Docker image..."
                                docker compose build --no-cache
                            else
                                docker compose build
                            fi
                            
                            echo "Starting services..."
                            docker compose up -d
                            
                            echo "Waiting for service to be healthy..."
                            sleep 10
                            
                            # Health check
                            for i in {1..30}; do
                                if curl -f http://localhost:${PORT} > /dev/null 2>&1; then
                                    echo "✅ Portfolio website is running!"
                                    break
                                fi
                                echo "Waiting for service... ($i/30)"
                                sleep 2
                            done
                        '''
                    }
                }
            }
        }
        
        stage('Status Check') {
            steps {
                script {
                    dir('/var/projects/nothing-to-add.github.io') {
                        sh '''
                            echo "=== SERVICE STATUS ==="
                            docker compose ps
                            
                            echo "\\n=== CONTAINER DETAILS ==="
                            docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"
                            
                            echo "\\n=== RESOURCE USAGE ==="
                            docker stats --no-stream --format "table {{.Container}}\\t{{.CPUPerc}}\\t{{.MemUsage}}" ${CONTAINER_NAME} || echo "Container not running"
                            
                            echo "\\n=== ACCESS INFO ==="
                            if docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" | grep -q ${CONTAINER_NAME}; then
                                echo "🌐 Portfolio Website: http://localhost:${PORT}"
                                echo "📱 Mobile Preview: http://localhost:${PORT}"
                                echo "🔧 Container Status: RUNNING"
                            else
                                echo "❌ Portfolio website is not running"
                            fi
                        '''
                    }
                }
            }
        }
        
        stage('Show Logs') {
            when { expression { params.ACTION == 'logs' } }
            steps {
                script {
                    dir('/var/projects/nothing-to-add.github.io') {
                        sh '''
                            echo "=== RECENT LOGS ==="
                            docker compose logs --tail=50 portfolio
                        '''
                    }
                }
            }
        }
    }
    
    post {
        success {
            script {
                if (params.ACTION == 'deploy' || params.ACTION == 'restart') {
                    currentBuild.description = "✅ Portfolio deployed at http://localhost:${env.PORT}"
                } else if (params.ACTION == 'stop') {
                    currentBuild.description = "⏹️ Portfolio stopped"
                } else {
                    currentBuild.description = "✅ Action '${params.ACTION}' completed"
                }
            }
        }
        failure {
            script {
                currentBuild.description = "❌ Action '${params.ACTION}' failed"
            }
        }
        always {
            script {
                echo "=== BUILD SUMMARY ==="
                echo "Action: ${params.ACTION}"
                echo "Status: ${currentBuild.currentResult}"
                echo "Duration: ${currentBuild.durationString}"
            }
        }
    }
}
