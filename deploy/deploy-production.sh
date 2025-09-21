# This is the corrected version of the production deployment workflow.
# It explicitly passes the DOCKERHUB_USERNAME and DOCKERHUB_TOKEN secrets
# to the ssh-action, making them available to the deployment script.
name: Deploy Production 🚀

on:
  release:
    types: [published, edited]

jobs:
  deploy-to-production-server:
    runs-on: ubuntu-latest
    environment: production

    steps:
      - name: Deploy to production server via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.SSH_HOST_PRODUCTION }}
          username: ${{ secrets.SSH_USER_NAME_PRODUCTION }}
          key: ${{ secrets.SSH_PRIVATE_KEY_PRODUCTION }}
          script: |
            # Export secrets so they are available to the shell script
            export DOCKERHUB_USERNAME=${{ secrets.DOCKERHUB_USERNAME }}
            export DOCKERHUB_TOKEN=${{ secrets.DOCKERHUB_TOKEN }}
            export APP_IMAGE=${{ secrets.DOCKERHUB_USERNAME }}/pacmusic
            export APP_TAG=${{ github.ref_name }}
            export APP_PROD_PORT=${{ vars.APP_PROD_PORT }}
            export MINIO_PROD_ENDPOINT=${{ secrets.MINIO_PROD_ENDPOINT }}
            export MINIO_PROD_ACCESS_KEY=${{ secrets.MINIO_PROD_ACCESS_KEY }}
            export MINIO_PROD_SECRET_KEY=${{ secrets.MINIO_PROD_SECRET_KEY }}
            
            # Navigate to the correct directory and execute the deployment script
            cd /home/ubuntu/production
            bash ./deploy/deploy-production.sh
