# Stern Logging Stack

This repository provides a local logging stack that uses **Stern** to tail logs from Kubernetes pods, **Fluent Bit** to process and forward them, and **Elasticsearch/Kibana** for storage and visualization.

## Architecture

The stack consists of the following components running in Docker:

1.  **stern-worker-dev**:
    -   Connects to your EKS cluster using your local AWS credentials and Kubeconfig.
    -   Uses [Stern](https://github.com/stern/stern) to tail logs from pods matching the pattern `microservice-pod-dev-(service_1|service_2|service_n)` in the `pod-dev` namespace. (you can change this with appropriate pattern of your system)
    -   Writes logs to a shared volume at `./shared-logs/stern.log`.
    -   Handles log rotation automatically to prevent file bloat.

2.  **fluent-bit**:
    -   Reads the `./shared-logs/stern.log` file.
    -   Parses JSON logs and handles multiline Java stack traces.
    -   Filters out noisy logs (e.g., Hibernate queries).
    -   Forwards processed logs to Elasticsearch.

3.  **elasticsearch**:
    -   Stores the logs.
    -   Accessible at `http://localhost:9200`.

4.  **kibana**:
    -   Web interface for searching and visualizing logs.
    -   Accessible at `http://localhost:5601`.

## Prerequisites

-   **Docker** and **Docker Compose** installed.
-   **AWS CLI** configured with access to the AWS EKS cluster.
-   **kubectl** configured with a valid context for the cluster.
-   **AWS Credentials**: The setup assumes your AWS credentials are located at `~/.aws/` and your kubeconfig at `~/.kube/`.

## Configuration

Create a `.env` file in the root directory to configure the stack. You can use the following environment variables:

| Variable | Description | Default / Example |
| :--- | :--- | :--- |
| `ELASTIC_PASSWORD` | Password for the `elastic` superuser. | `changeme` |
| `ELASTICSEARCH_USERNAME` | Username for Kibana to connect to Elasticsearch. | `kibana_system` |
| `ELASTICSEARCH_PASSWORD` | Password for the `kibana_system` user. | `changeme` |
| `AWS_PROFILE` | The AWS CLI profile to use from your local credentials. | `default` |
| `STERN_POD_QUERY` | Regex pattern for Stern to select pods to tail. | `microservice-pod-dev-(service_1\|service_2)` |

## How to Run

1.  **Start the stack:**

    ```bash
    docker-compose up -d
    ```

2.  **Access Kibana:**

    Open [http://localhost:5601](http://localhost:5601) in your browser.
    -   **Username**: `elastic`
    -   **Password**: whatever you set in `docker-compose.yaml`

3.  **Check Logs:**

    You can check the status of the stern worker to ensure it's connected and tailing logs:

    ```bash
    docker logs -f stern-worker-dev
    ```

## Directory Structure

-   `fluent-bit/`: Configuration for Fluent Bit pipeline (inputs, filters, outputs).
-   `logrotate/`: Configuration for log rotation inside the worker container.
-   `shared-logs/`: Shared volume where `stern` writes logs and `fluent-bit` reads them. **Ignored in git.**
-   `loki/`: (Optional/Inactive) Configuration for Loki if enabled.

## Troubleshooting

-   **No logs in Kibana?**
    -   Check if `stern-worker-dev` is successfully tailing logs: `docker logs stern-worker-dev`.
    -   Check Fluent Bit logs for parsing errors: `docker logs fluent-bit-dev`.
    -   Ensure your AWS credentials have expired or are valid.
-   **Elasticsearch connection refused?**
    -   Elasticsearch takes a moment to start. Wait a minute and try again.
