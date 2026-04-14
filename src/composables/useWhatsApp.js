import { buildWALink, buildWALinkFromLead, WA_TEMPLATES } from '@/utils/whatsapp'
import { ref } from 'vue'

export function useWhatsApp() {
  const copied = ref(false)

  async function copyText(text) {
    await navigator.clipboard.writeText(text)
    copied.value = true
    setTimeout(() => (copied.value = false), 2000)
  }

  function openLink(url) {
    window.open(url, '_blank')
  }

  return { copied, copyText, openLink, buildWALink, buildWALinkFromLead, WA_TEMPLATES }
}
