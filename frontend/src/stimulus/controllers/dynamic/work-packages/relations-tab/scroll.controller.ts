import { Controller } from '@hotwired/stimulus';

export default class ScrollController extends Controller {
  private observer:MutationObserver;

  connect() {
    this.observer = new MutationObserver(this.scrollToAddedRelation.bind(this));

    this.observer.observe(document.body, {
      childList: true,
      subtree: true,
    });
  }

  disconnect() {
    this.observer?.disconnect();
  }

  scrollToAddedRelation(_mutations:MutationRecord[]) {
    const element = this.element.querySelector('[data-scroll-to-relation="true"]');
    if (element) {
      element.scrollIntoView({ behavior: 'smooth', block: 'center' });
      this.observer.disconnect(); // Stop observing once found
    }
  }
}
