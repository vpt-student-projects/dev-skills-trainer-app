#!/bin/bash
set -e

echo "🐰 Инициализация RabbitMQ..."

# Создать vhost
rabbitmqctl add_vhost /

# Создать пользователя с правами
rabbitmqctl add_user ${RABBITMQ_USER} ${RABBITMQ_PASS}
rabbitmqctl set_user_tags ${RABBITMQ_USER} administrator
rabbitmqctl set_permissions -p / ${RABBITMQ_USER} ".*" ".*" ".*"

# Создать очереди для задач
rabbitmqadmin declare queue name=task_queue durable=true

echo "✅ RabbitMQ настроен автоматически!"