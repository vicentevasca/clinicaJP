import { gsap } from 'gsap'
import { onMounted, onBeforeUnmount, ref } from 'vue'

export function useGsap(targetRef) {
  const ctx = ref(null)

  function fadeIn(el, vars = {}) {
    return gsap.from(el, { opacity: 0, duration: 0.4, ease: 'power2.out', ...vars })
  }

  function slideUp(el, vars = {}) {
    return gsap.from(el, { opacity: 0, y: 20, duration: 0.4, ease: 'power2.out', ...vars })
  }

  function staggerIn(els, vars = {}) {
    return gsap.from(els, { opacity: 0, y: 16, duration: 0.35,
      stagger: 0.07, ease: 'power2.out', ...vars })
  }

  onBeforeUnmount(() => ctx.value?.revert())

  return { fadeIn, slideUp, staggerIn }
}
