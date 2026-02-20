# Portfolio Website - Jenkins CI/CD Setup Guide

This guide explains how to set up and use Jenkins for local development and deployment of your portfolio website.

## 🎯 **Next Steps to Set Up Jenkins Pipeline**

### **1. Create Jenkins Job**

1. **Open Jenkins**: Navigate to `http://localhost:8080` in your browser
2. **Create New Pipeline**:
   - Click **"New Item"**
   - Enter name: **`portfolio-website`**
   - Select **"Pipeline"**
   - Click **"OK"**

3. **Configure Pipeline**:
   - **Pipeline Definition**: Select "Pipeline script from SCM"
   - **SCM**: Select "None (local files)"
   - **Script Path**: Enter `/var/projects/nothing-to-add.github.io/Jenkinsfile`
   - Click **"Save"**

### **2. Test Local Deployment**

Before using Jenkins, test the deployment manually to ensure everything works:

```bash
# Navigate to your project directory
cd /Users/maksims.laitans/SwiftProjects/nothing-to-add.github.io

# Build and start the website
docker-compose up -d

# Check if it's running
docker-compose ps

# Visit your website
open http://localhost:3000

# Stop the website when done testing
docker-compose down
```

### **3. Jenkins Pipeline Actions**

Your Jenkins pipeline supports these actions through build parameters:

- **🚀 Deploy**: Build and start the website
- **⏹️ Stop**: Stop the running website  
- **🔄 Restart**: Stop and restart the website
- **📊 Status**: Check if website is running and show resource usage
- **📋 Logs**: View container logs for troubleshooting

**Additional Options**:
- **🧹 Cleanup Old**: Remove old containers and images
- **🔨 Force Rebuild**: Force rebuild Docker image from scratch

## 📋 **What Each File Does**

### **Dockerfile**
- **Uses Nginx Alpine**: Lightweight web server (only ~5MB)
- **Copies your HTML/CSS/JS**: All website files served statically
- **Adds health checks**: Monitors if website is responding
- **Exposes port 80**: Standard web traffic port inside container

### **docker-compose.yml**
- **Builds your portfolio**: Creates container from your code
- **Maps port 3000**: Access via `http://localhost:3000`
- **Adds labels**: Tags for Jenkins management and identification
- **Includes health checks**: Automatic container health monitoring
- **Restart policies**: Auto-restart if container crashes

### **Jenkinsfile**
- **Complete CI/CD pipeline**: Full automation for build and deployment
- **Build parameters**: Interactive options for different actions
- **Deploy/Stop/Restart**: All lifecycle management actions
- **Health monitoring**: Checks if website is accessible
- **Resource usage**: Shows CPU and memory consumption
- **Automatic cleanup**: Optional removal of old containers/images

### **.dockerignore**
- **Excludes unnecessary files**: Git files, documentation, IDE configs
- **Reduces image size**: Faster builds and smaller containers
- **Improves build speed**: Less data to copy during Docker build
- **Security**: Prevents sensitive files from being included

## 🚀 **Usage Workflow**

### **Daily Development Workflow**

1. **Start Jenkins** (from your separate Jenkins repo):
   ```bash
   cd ~/Development/jenkins-local
   docker-compose up -d
   ```

2. **Create the pipeline job** (one-time setup):
   - Follow the "Create Jenkins Job" steps above

3. **Deploy your website**:
   - Open Jenkins: `http://localhost:8080`
   - Click on **"portfolio-website"** job
   - Click **"Build with Parameters"**
   - Select **ACTION**: `deploy`
   - Click **"Build"**

4. **Access your website**:
   - Visit: `http://localhost:3000`
   - Your portfolio is now running locally!

5. **Make changes to your code**:
   - Edit HTML, CSS, or JS files
   - Save your changes

6. **Update the running website**:
   - Go back to Jenkins
   - Run pipeline again with **ACTION**: `restart`
   - Your changes will be live at `http://localhost:3000`

7. **Stop development**:
   - Run pipeline with **ACTION**: `stop`
   - This frees up system resources

### **Troubleshooting Workflow**

1. **Check Status**:
   - Run pipeline with **ACTION**: `status`
   - Shows if website is running and resource usage

2. **View Logs**:
   - Run pipeline with **ACTION**: `logs`
   - Shows recent container logs for debugging

3. **Clean Restart**:
   - Run pipeline with **ACTION**: `deploy`
   - Enable **CLEANUP_OLD**: `true`
   - Enable **FORCE_REBUILD**: `true`
   - This starts completely fresh

## 🎛️ **Jenkins Pipeline Parameters**

When running the pipeline, you can customize the behavior:

### **ACTION Parameter**
- **`deploy`**: Build and start the website
- **`stop`**: Stop the running website
- **`restart`**: Stop and restart (useful after code changes)
- **`status`**: Check running status and resource usage
- **`logs`**: View recent container logs

### **CLEANUP_OLD Parameter**
- **`false`** (default): Keep old containers and images
- **`true`**: Remove old containers and images to free space

### **FORCE_REBUILD Parameter**
- **`false`** (default): Use cached Docker layers for faster builds
- **`true`**: Rebuild everything from scratch (slower but ensures fresh build)

## 🔍 **Monitoring & Maintenance**

### **Check Website Status**
```bash
# Quick status check
docker ps --filter "name=portfolio-website"

# Resource usage
docker stats portfolio-website --no-stream

# Health check
curl -f http://localhost:3000 && echo "✅ Website is healthy"
```

### **Manual Container Management**
```bash
# If you need to manage containers outside Jenkins:

# Stop website
docker-compose down

# Start website  
docker-compose up -d

# View logs
docker-compose logs -f portfolio

# Rebuild and restart
docker-compose up -d --build
```

### **Cleanup Commands**
```bash
# Remove stopped containers
docker container prune -f

# Remove unused images
docker image prune -f

# Full system cleanup (careful!)
docker system prune -f
```

## 🛠️ **Advanced Configuration**

### **Custom Port**
To use a different port, edit `docker-compose.yml`:
```yaml
ports:
  - "8080:80"  # Changes from 3000 to 8080
```

### **Development vs Production**
For production deployment, consider:
- Using environment variables for configuration
- Adding SSL/TLS certificates
- Setting up domain names
- Adding monitoring and logging services

### **Multiple Environments**
You can create multiple Jenkins jobs:
- `portfolio-development` (port 3000)
- `portfolio-staging` (port 3001)
- `portfolio-production` (port 3002)

## 🎉 **Success Indicators**

Your setup is working correctly when:
- ✅ Jenkins job runs without errors
- ✅ Website accessible at `http://localhost:3000`
- ✅ Changes to code reflect after pipeline restart
- ✅ Container health checks pass
- ✅ No port conflicts or resource issues

## 📞 **Getting Help**

### **Common Issues**
- **Port 3000 in use**: Change port in `docker-compose.yml`
- **Permission denied**: Check Docker permissions
- **Build fails**: Check Dockerfile syntax and file paths
- **Website not loading**: Check container logs and health checks

### **Useful Resources**
- **Jenkins Documentation**: https://www.jenkins.io/doc/
- **Docker Compose Reference**: https://docs.docker.com/compose/
- **Nginx Configuration**: https://nginx.org/en/docs/

---

Your portfolio project is now ready for professional Jenkins-managed deployment! 🎉

This setup provides you with:
- **Professional CI/CD pipeline**
- **Local development environment**
- **Easy deployment management**  
- **Production-ready containerization**
- **Monitoring and troubleshooting tools**
