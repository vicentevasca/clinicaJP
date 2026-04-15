#!/usr/bin/env bash
# VetDesk — Deploy Edge Functions
# Usage: SUPABASE_ACCESS_TOKEN=xxx ./scripts/deploy-functions.sh
# Get token at: https://supabase.com/dashboard/account/tokens

set -e

TOKEN="${SUPABASE_ACCESS_TOKEN:-}"
if [ -z "$TOKEN" ]; then
  echo "❌ SUPABASE_ACCESS_TOKEN not set"
  echo "Get your token at: https://supabase.com/dashboard/account/tokens"
  echo "Then run: SUPABASE_ACCESS_TOKEN=xxx ./scripts/deploy-functions.sh"
  exit 1
fi

PROJECT_REF="nijpbzmvtfranlghejip"
FUNCTIONS_DIR="supabase/functions"

echo "🔗 Linking project..."
npx supabase link --project-ref "$PROJECT_REF" --access-token "$TOKEN"

echo ""
echo "🚀 Deploying Edge Functions..."

deploy_function() {
  local name=$1
  echo "  Deploying $name..."
  npx supabase functions deploy "$name" --access-token "$TOKEN" --project-ref "$PROJECT_REF"
  echo "  ✓ $name deployed"
}

deploy_function "create-lead"
deploy_function "close-visit"
deploy_function "telegram-webhook"
deploy_function "whatsapp-preview"
deploy_function "send-email"

echo ""
echo "📡 Configuring Telegram webhook..."
curl -s -X POST "https://api.telegram.org/bot8662662849:AAFMxOqB47pb-2fvXvYEDsXucxlIV2ej2lE/setWebhook" \
  -H "Content-Type: application/json" \
  -d "{\"url\": \"https://${PROJECT_REF}.supabase.co/functions/v1/telegram-webhook\", \"secret_token\": \"vetdesk_telegram_secret_2024\"}"

echo ""
echo ""
echo "✅ ¡Todo desplegado!"
echo ""
echo "   Panel VetDesk: https://clinica-4a7saoqig-vicevasca-5840s-projects.vercel.app/app"
echo "   Leads:        /app/leads"
echo "   Agenda:        /app/agenda"
echo ""
