import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["sidebar"]

  connect() {
    if (this.isUserAuthorized()) {
      this.toggleSidebar();
    }
  }

  isUserAuthorized() {
    // Add your logic here to check if the user is authorized
    // For example, you can check if the current_user variable is not nil
    return typeof current_user !== 'undefined' && current_user !== null;
  }

  toggleSidebar() {
    this.sidebarTarget.classList.toggle('d-md-block');
  }
}