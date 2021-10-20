// import forEach from 'lodash/forEach';
import { hide, show } from './helpers'
// import { searchOnUserInput } from './modules/proceedings'
//
// function ModalDialogue () {}
//
// ModalDialogue.prototype.start = function ($module) {
//   this.$module = $module;
//   this.$dialogBox = this.$module.querySelector('.js-modal-dialog');
//   this.$closeButton = this.$module.querySelector(
//     '.js-modal-dialog-close-button--main'
//   );
//   this.$allCloseButtons = this.$module.querySelectorAll(
//     '.js-modal-dialog-close-button'
//   );
//   this.$body = document.querySelector('body');
//
//   this.$module.open = this.handleOpen.bind(this);
//   this.$module.close = this.handleClose.bind(this);
//   this.$module.focusDialog = this.handleFocusDialog.bind(this);
//   this.$module.boundKeyDown = this.handleKeyDown.bind(this);
//
//   const $triggerElement = document.querySelector(
//     '[data-toggle="modal"][data-target="' + this.$module.id + '"]'
//   );
//
//   if ($triggerElement) {
//     $triggerElement.addEventListener('click', this.$module.open);
//   }
//
//   if (this.$allCloseButtons) {
//     this.$allCloseButtons.forEach((el) => {
//       el.addEventListener('click', this.$module.close);
//     });
//   }
// };
//
// ModalDialogue.prototype.handleOpen = function (event) {
//   if (event) {
//     event.preventDefault();
//   }
//
//   // Close any currently-open modal
//   const currentOpenModal = this.$body.querySelector(
//     '[data-modal-open="true"]'
//   );
//   if (currentOpenModal) {
//     currentOpenModal.close();
//   }
//
//   this.$body.classList.add('is-modal');
//   this.$focusedElementBeforeOpen = document.activeElement;
//   show(this.$module)
//   this.$module.setAttribute('data-modal-open', true);
//   this.$dialogBox.focus();
//
//   document.addEventListener('keydown', this.$module.boundKeyDown, true);
// };
//
// ModalDialogue.prototype.handleClose = function (event) {
//   if (event) {
//     event.preventDefault();
//   }
//
//   this.$body.classList.remove('is-modal');
//   hide(this.$module);
//   this.$module.removeAttribute('data-modal-open');
//   this.$focusedElementBeforeOpen.focus();
//
//   document.removeEventListener('keydown', this.$module.boundKeyDown, true);
// };
//
// ModalDialogue.prototype.handleFocusDialog = function () {
//   this.$dialogBox.focus();
// };
//
// // while open, prevent tabbing to outside the dialogue
// // and listen for ESC key to close the dialogue
// ModalDialogue.prototype.handleKeyDown = function (event) {
//   const KEY_TAB = 9;
//   const KEY_ESC = 27;
//
//   const focusableModalElements = this.$module.querySelectorAll(
//     'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
//   );
//
//   // Some modals don't have close buttons so we need to find the last focusable element in the modal
//   // to keep tab keypresses within the modal and not the (hidden) document underneath
//   const lastFocusableElement = this.$closeButton
//     ? this.$closeButton
//     : focusableModalElements[focusableModalElements.length - 1];
//
//   switch (event.keyCode) {
//     case KEY_TAB:
//       if (event.shiftKey) {
//         if (document.activeElement === this.$dialogBox) {
//           event.preventDefault();
//           lastFocusableElement.focus();
//         }
//       } else {
//         if (document.activeElement === lastFocusableElement) {
//           event.preventDefault();
//           this.$dialogBox.focus();
//         }
//       }
//
//       break;
//     case KEY_ESC:
//       if (this.$closeButton) {
//         this.$module.close();
//       }
//       break;
//     default:
//       break;
//   }
// };
//
// function init () {
//   const modalStartedAttr = 'data-modal-started';
//   const modalElements = document.querySelectorAll('[data-modal]');
//   modalElements.forEach((el) => {
//     const started = el.getAttribute(modalStartedAttr);
//     if (!started) {
//       const modal = new ModalDialogue();
//       modal.start(el);
//       el.setAttribute(modalStartedAttr, true);
//     }
//   });
// }
//
// // Allow triggering a modal via JavaScript if you know its ID
// function triggerModal (id) {
//   const modal = document.getElementById(id);
//   console.log('modal triggered')
//   if (modal && modal.open) {
//     modal.open();
//   }
// }
//
// document.addEventListener('DOMContentLoaded', event => {
//   init()
// })
//
// export default {
//   init,
//   triggerModal,
// };

document.addEventListener('DOMContentLoaded', event => {

  const deleteButton = document.querySelector(
    '[data-toggle="modal"][data-target="delete-modal"]'
  )

  if (deleteButton) {
    const modal = document.getElementById('delete-modal');
    // When the user clicks on the button, open the modal
    deleteButton.addEventListener('click', () => {
      show(modal)
    })

    // Get the <span> element that closes the modal
    const span = document.getElementsByClassName('close')[0];
    // When the user clicks on <span> (x), close the modal
    span.onclick = function () {
      hide(modal)
    }

    // When the user clicks anywhere outside of the modal, close it
    window.onclick = function (event) {
      if (event.target === modal) {
        hide(modal)
      }
    }
  }
})
