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
            # Navigate to the correct directory first.
            cd /home/ubuntu/production
            
            # Execute the deployment script with all secrets and variables
            # passed directly into its environment. This is the most reliable method.
            DOCKERHUB_USERNAME=${{ secrets.DOCKERHUB_USERNAME }} \
            DOCKERHUB_TOKEN=${{ secrets.DOCKERHUB_TOKEN }} \
            APP_IMAGE=${{ secrets.DOCKERHUB_USERNAME }}/pacmusic \
            APP_TAG=${{ github.ref_name }} \
            APP_PROD_PORT=${{ vars.APP_PROD_PORT }} \
            MINIO_PROD_ENDPOINT=${{ secrets.MINIO_PROD_ENDPOINT }} \
            MINIO_PROD_ACCESS_KEY=${{ secrets.MINIO_PROD_ACCESS_KEY }} \
            MINIO_PROD_SECRET_KEY=${{ secrets.MINIO_PROD_SECRET_KEY }} \
            bash ./deploy/deploy-production.sh
