// let presets = [];

// window.addEventListener('message', function(event) {
//     const data = event.data;
//     if (data.action === 'open') {
//         document.getElementById('invoice').style.display = 'block';

//         const playersDropdown = document.getElementById('players');
//         playersDropdown.innerHTML = '';
//         data.players.forEach(player => {
//             let option = document.createElement('option');
//             option.value = player.id;
//             option.textContent = player.name;
//             playersDropdown.appendChild(option);
//         });

//         presets = data.presets;
//         displayPresets(presets);
//     }
// });

// function displayPresets(presets) {
//     const presetSelect = document.getElementById('presets');
//     presetSelect.innerHTML = '';

//     presets.forEach(amount => {
//         const option = document.createElement('option');
//         option.value = amount;
//         option.textContent = `$${amount}`;
//         presetSelect.appendChild(option);
//     });

//     if (presets.length > 0) {
//         presetSelect.style.display = 'block';
//     } else {
//         presetSelect.style.display = 'none';
//     }
// }

// function filterPresets() {
//     const query = document.getElementById('presetSearch').value.toLowerCase();
//     const filteredPresets = presets.filter(amount => amount.toString().toLowerCase().includes(query));
//     displayPresets(filteredPresets);
// }

// function selectPreset() {
//     const presetSelect = document.getElementById('presets');
//     const selectedValue = presetSelect.value;
//     document.getElementById('amount').value = selectedValue;
// }

// // Guarda el preset
// function savePreset() {
//     const amount = document.getElementById('presetAmount').value;
//     fetch(`https://${GetParentResourceName()}/savePreset`, {
//         method: 'POST',
//         headers: { 'Content-Type': 'application/json' },
//         body: JSON.stringify({ amount })
//     }).then(response => response.json())
//     .then(data => {
//         if (data.status === 'ok') {
//             console.log('Preset guardado exitosamente');
//             presets.push(amount);
//             displayPresets(presets);
//         } else {
//             console.error('Error al guardar el preset');
//         }
//     });
// }

// function sendInvoice() {
//     const playerId = document.getElementById('players').value;
//     const amount = document.getElementById('amount').value;
//     fetch(`https://${GetParentResourceName()}/sendInvoice`, {
//         method: 'POST',
//         headers: { 'Content-Type': 'application/json' },
//         body: JSON.stringify({ playerId, amount })
//     });
//     closeMenu();
// }

// function closeMenu() {
//     document.getElementById('invoice').style.display = 'none';
//     fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
// }

// function deletePreset() {
//     const presetSelect = document.getElementById('presets');
//     const selectedValue = presetSelect.value;

//     if (selectedValue) {
//         fetch(`https://${GetParentResourceName()}/deletePreset`, {
//             method: 'POST',
//             headers: { 'Content-Type': 'application/json' },
//             body: JSON.stringify({ amount: selectedValue })
//         })
//         .then(response => response.json())
//         .then(data => {
//             if (data.status === 'ok') {
//                 console.log('Preset eliminado exitosamente');
//                 presets = presets.filter(amount => amount !== selectedValue);
//                 displayPresets(presets);
//             } else {
//                 console.error('Error al eliminar el preset:', data.message);
//             }
//         })
//         .catch(err => {
//             console.error('Error en la solicitud de eliminación:', err);
//         });
//     } else {
//         console.log('Por favor selecciona un preset para eliminar.');
//     }
// }

// window.addEventListener('message', function(event) {
//     const data = event.data;
//     if (data.action === 'deletePresetResponse') {
//         if (data.status === 'ok') {
//             console.log('Preset eliminado exitosamente');
//         } else {
//             console.error('Error al eliminar el preset:', data.message);
//         }
//     }
// });

let presets = [];
let isOpen = false;
let locale = {};

window.addEventListener("message", function (event) {
  const data = event.data;

  if (data.action === "open") {
    const invoice = document.getElementById("invoice");

    if (!isOpen) {
      invoice.classList.remove("top", "bottom", "left", "right");
      invoice.classList.add(data.position);

      let animation;

      if (data.position === "top") {
        animation = "slideInTop 0.5s ease-out";
      } else if (data.position === "bottom") {
        animation = "slideInBottom 0.5s ease-out";
      } else if (data.position === "left") {
        animation = "slideInLeft 0.5s ease-out";
      } else if (data.position === "right") {
        animation = "slideInRight 0.5s ease-out";
      }

      invoice.style.animation = animation;
      invoice.style.display = "block";
      invoice.style.opacity = "1";

      const playersDropdown = document.getElementById("players");
      playersDropdown.innerHTML = "";
      data.players.forEach((player) => {
        let option = document.createElement("option");
        option.value = player.id;
        option.textContent = player.name;
        playersDropdown.appendChild(option);
      });

      presets = data.presets;
      displayPresets(presets);
      isOpen = true;

      locale = data.locale;
      updateUI();
    }
  }
});

function displayPresets(presets) {
    const presetSelect = document.getElementById("presets");
    presetSelect.innerHTML = "";
  
    presets.forEach((preset) => {
      const option = document.createElement("option");
      option.value = preset.amount;
      option.textContent = `${preset.label} - $${preset.amount}`;
      presetSelect.appendChild(option);
    });
  
    presetSelect.style.display = presets.length > 0 ? "block" : "none";
  
    presetSelect.onchange = selectPreset;
  }
  

  function filterPresets() {
    const query = document.getElementById("presetSearch").value.toLowerCase();
    const filteredPresets = presets.filter(
      (preset) =>
        preset.label.toLowerCase().includes(query) ||
        preset.amount.toString().includes(query)
    );
    
    displayPresets(filteredPresets);
    
    if (filteredPresets.length === 1) {
      const presetSelect = document.getElementById("presets");
      presetSelect.value = filteredPresets[0].amount;
      selectPreset();
    }
  }
  

function selectPreset() {
    const presetSelect = document.getElementById("presets");
    const selectedOption = presetSelect.options[presetSelect.selectedIndex];
    if (selectedOption) {
      const selectedValue = presetSelect.value;
  
      document.getElementById("description").value = selectedOption.textContent.split(" - ")[0];
      document.getElementById("amount").value = selectedValue;
    }
  }
  
function sendInvoice() {
  const playerId = document.getElementById("players").value;
  const amount = document.getElementById("amount").value;
  const label = document.getElementById("description").value;

  fetch(`https://${GetParentResourceName()}/sendInvoice`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ playerId, amount, label }),
  });
  closeMenu();
}

function closeMenu() {
  const invoice = document.getElementById("invoice");
  let animation;

  if (invoice.classList.contains("right")) {
    animation = "closeRight 0.5s ease-out";
  } else if (invoice.classList.contains("left")) {
    animation = "closeLeft 0.5s ease-out";
  } else if (invoice.classList.contains("top")) {
    animation = "closeTop 0.5s ease-out";
  } else if (invoice.classList.contains("bottom")) {
    animation = "closeBottom 0.5s ease-out";
  }

  invoice.style.animation = animation;

  setTimeout(() => {
    invoice.style.display = "none";
    isOpen = false;
  }, 500);
  fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}

function updateUI() {
  document.querySelector("h2").innerText = locale["invoice_title"];
  document.getElementById("labelPlayer").innerText = locale["label_player"];
  document.getElementById("labelAmount").innerText = locale["label_amount"];
  document.getElementById("labelPresetSearch").innerText =
    locale["label_preset_search"];
  document.getElementById("labelPresets").innerText = locale["label_presets"];
  document.getElementById("labelDescription").innerText =
    locale["label_description"];
  document.querySelector('button[onclick="sendInvoice()"]').innerText =
    locale["button_send"];
  document.querySelector('button[onclick="closeMenu()"]').innerText =
    locale["button_close"];
}

function savePreset() {
  const amount = document.getElementById("presetAmount").value;
  fetch(`https://${GetParentResourceName()}/savePreset`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ amount }),
  })
    .then((response) => response.json())
    .then((data) => {
      if (data.status === "ok") {
        presets.push(amount);
        displayPresets(presets);
      }
    });
}

function deletePreset() {
  const presetSelect = document.getElementById("presets");
  const selectedValue = presetSelect.value;

  if (selectedValue) {
    fetch(`https://${GetParentResourceName()}/deletePreset`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ amount: selectedValue }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.status === "ok") {
          presets = presets.filter((amount) => amount !== selectedValue);
          displayPresets(presets);
        }
      })
      .catch((err) => {
        console.error("Error en la solicitud de eliminación:", err);
      });
  }
}
