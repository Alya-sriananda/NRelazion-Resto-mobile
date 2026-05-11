<!-- referensi tampilan pilihan meja -->
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keranjang & Pilih Meja</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f5f2;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            background-color: #fdf6f3;
            border-radius: 20px;
            padding: 28px;
            width: 100%;
            max-width: 480px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.06);
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }
        .header h2 {
            font-size: 24px;
            font-weight: 700;
            color: #2c2c2c;
        }
        .badge {
            background-color: #e8e0fc;
            color: #6b4ee6;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }
        .categories {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            overflow-x: auto;
            padding-bottom: 4px;
        }
        .category-btn {
            padding: 10px 20px;
            border-radius: 12px;
            border: 1.5px solid #ddd;
            background-color: #fff;
            color: #555;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            white-space: nowrap;
            min-width: fit-content;
        }
        .category-btn:hover {
            border-color: #6b4ee6;
            color: #6b4ee6;
        }
        .category-btn.active {
            background-color: #6b4ee6;
            color: #fff;
            border-color: #6b4ee6;
        }
        .tables-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(70px, 1fr));
            gap: 14px;
            margin-bottom: 28px;
        }
        .table-card {
            aspect-ratio: 1;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
            border: 2px solid transparent;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .table-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.1);
        }
        .table-card.tersedia {
            background-color: #e8f5e9;
            color: #2e7d32;
            border-color: #a5d6a7;
        }
        .table-card.tersedia:hover {
            background-color: #c8e6c9;
        }
        .table-card.terisi {
            background-color: #ffebee;
            color: #c62828;
            border-color: #ef9a9a;
            cursor: not-allowed;
        }
        .table-card.reserved {
            background-color: #fff9c4;
            color: #f57f17;
            border-color: #fff176;
            cursor: not-allowed;
        }
        .table-card.selected {
            background-color: #bf360c;
            color: #fff;
            border-color: #bf360c;
            box-shadow: 0 4px 16px rgba(191, 54, 12, 0.3);
        }
        .legend {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }
        .legend-item {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            color: #666;
        }
        .legend-dot {
            width: 14px;
            height: 14px;
            border-radius: 4px;
        }
        .summary {
            background-color: #fff;
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 16px;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            font-size: 14px;
            color: #666;
        }
        .summary-row.total {
            font-size: 18px;
            font-weight: 700;
            color: #2c2c2c;
            border-top: 1px dashed #ddd;
            padding-top: 12px;
            margin-top: 8px;
            margin-bottom: 0;
        }
        .btn-order {
            width: 100%;
            padding: 16px;
            background-color: #6b4ee6;
            color: #fff;
            border: none;
            border-radius: 14px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }
        .btn-order:hover {
            background-color: #5a3fd1;
        }
        .btn-order:disabled {
            background-color: #ccc;
            cursor: not-allowed;
        }
        .selected-info {
            text-align: center;
            margin-bottom: 16px;
            font-size: 14px;
            color: #555;
            min-height: 20px;
        }
        .selected-info span {
            font-weight: 700;
            color: #6b4ee6;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Pilih Meja</h2>
            <span class="badge">Required</span>
        </div>

        <div class="categories" id="categories">
            <button class="category-btn active" data-cat="Lesehan">Lesehan</button>
            <button class="category-btn" data-cat="Garden">Garden</button>
            <button class="category-btn" data-cat="Area L">Area L</button>
            <button class="category-btn" data-cat="Atap">Atap</button>
            <button class="category-btn" data-cat="VIP">VIP</button>
        </div>

        <div class="legend">
            <div class="legend-item">
                <div class="legend-dot" style="background:#e8f5e9; border:2px solid #a5d6a7;"></div>
                <span>Tersedia</span>
            </div>
            <div class="legend-item">
                <div class="legend-dot" style="background:#ffebee; border:2px solid #ef9a9a;"></div>
                <span>Terisi</span>
            </div>
            <div class="legend-item">
                <div class="legend-dot" style="background:#fff9c4; border:2px solid #fff176;"></div>
                <span>Reserved</span>
            </div>
        </div>

        <div class="tables-grid" id="tablesGrid"></div>

        <div class="selected-info" id="selectedInfo">Belum memilih meja</div>

        <div class="summary">
            <div class="summary-row">
                <span>Subtotal</span>
                <span>Rp 125.000</span>
            </div>
            <div class="summary-row">
                <span>PPN (10%)</span>
                <span>Rp 12.500</span>
            </div>
            <div class="summary-row">
                <span>Service Charge</span>
                <span>Rp 5.000</span>
            </div>
            <div class="summary-row total">
                <span>Total Pesanan</span>
                <span>Rp 142.500</span>
            </div>
        </div>

        <button class="btn-order" id="btnOrder" disabled>Pesan Sekarang</button>
    </div>

    <script>
        // Data meja per kategori
        const tablesData = {
            "Lesehan": [
                { id: 1, status: "tersedia" },
                { id: 2, status: "terisi" },
                { id: 3, status: "tersedia" },
                { id: 4, status: "reserved" },
                { id: 5, status: "tersedia" },
                { id: 6, status: "terisi" },
                { id: 7, status: "tersedia" },
                { id: 8, status: "tersedia" },
            ],
            "Garden": [
                { id: 1, status: "tersedia" },
                { id: 2, status: "tersedia" },
                { id: 3, status: "reserved" },
                { id: 4, status: "terisi" },
                { id: 5, status: "tersedia" },
                { id: 6, status: "tersedia" },
            ],
            "Area L": [
                { id: 1, status: "terisi" },
                { id: 2, status: "terisi" },
                { id: 3, status: "tersedia" },
                { id: 4, status: "tersedia" },
                { id: 5, status: "reserved" },
                { id: 6, status: "tersedia" },
                { id: 7, status: "terisi" },
                { id: 8, status: "tersedia" },
                { id: 9, status: "tersedia" },
                { id: 10, status: "reserved" },
            ],
            "Atap": [
                { id: 1, status: "tersedia" },
                { id: 2, status: "tersedia" },
                { id: 3, status: "tersedia" },
                { id: 4, status: "terisi" },
                { id: 5, status: "reserved" },
                { id: 6, status: "tersedia" },
                { id: 7, status: "tersedia" },
                { id: 8, status: "terisi" },
            ],
            "VIP": [
                { id: 1, status: "reserved" },
                { id: 2, status: "tersedia" },
                { id: 3, status: "terisi" },
                { id: 4, status: "tersedia" },
                { id: 5, status: "tersedia" },
            ]
        };

        let currentCategory = "Lesehan";
        let selectedTable = null;

        const categoriesEl = document.getElementById('categories');
        const tablesGridEl = document.getElementById('tablesGrid');
        const selectedInfoEl = document.getElementById('selectedInfo');
        const btnOrder = document.getElementById('btnOrder');

        function renderTables(category) {
            tablesGridEl.innerHTML = '';
            const tables = tablesData[category] || [];
            
            tables.forEach(table => {
                const card = document.createElement('div');
                card.className = `table-card ${table.status}`;
                card.textContent = table.id;
                card.dataset.id = table.id;
                card.dataset.status = table.status;
                
                if (table.status === 'tersedia') {
                    card.addEventListener('click', () => selectTable(table.id, card));
                }
                
                tablesGridEl.appendChild(card);
            });
        }

        function selectTable(id, cardEl) {
            // Remove previous selection
            document.querySelectorAll('.table-card').forEach(c => {
                if (c.dataset.status === 'tersedia') {
                    c.classList.remove('selected');
                }
            });
            
            // Add selection to clicked card
            cardEl.classList.add('selected');
            selectedTable = { category: currentCategory, id: id };
            
            selectedInfoEl.innerHTML = `Meja terpilih: <span>${currentCategory} - Meja ${id}</span>`;
            btnOrder.disabled = false;
        }

        // Category click handler
        categoriesEl.addEventListener('click', (e) => {
            if (e.target.classList.contains('category-btn')) {
                document.querySelectorAll('.category-btn').forEach(btn => btn.classList.remove('active'));
                e.target.classList.add('active');
                currentCategory = e.target.dataset.cat;
                selectedTable = null;
                selectedInfoEl.textContent = 'Belum memilih meja';
                btnOrder.disabled = true;
                renderTables(currentCategory);
            }
        });

        btnOrder.addEventListener('click', () => {
            if (selectedTable) {
                alert(`Pesanan dikonfirmasi!\nMeja: ${selectedTable.category} - Meja ${selectedTable.id}`);
            }
        });

        // Initial render
        renderTables(currentCategory);
    </script>
</body>
</html>

<!-- referensi style navigasi dengan bottom bar-->
<!-- From Uiverse.io by cf2-exe --> 
<div
  class="flex justify-center items-center relative transition-all duration-[450ms] ease-in-out w-auto"
>
  <article
    class="border border-solid border-gray-700 w-full ease-in-out duration-500 left-0 rounded-2xl flex shadow-lg shadow-black/15 bg-white"
  >
    <label
      class="has-[:checked]:shadow-lg relative w-full h-16 p-4 ease-in-out duration-300 border-solid border-black/10 has-[:checked]:border group flex flex-row gap-3 items-center justify-center text-black rounded-xl"
      for="dashboard"
    >
      <input
        id="dashboard"
        name="path"
        type="radio"
        class="hidden peer/expand"
      />
      <svg
        viewBox="0 0 24 24"
        height="24"
        width="24"
        xmlns="http://www.w3.org/2000/svg"
        class="peer-hover/expand:scale-125 peer-hover/expand:text-blue-400 peer-hover/expand:fill-blue-400 peer-checked/expand:text-blue-400 peer-checked/expand:fill-blue-400 text-2xl peer-checked/expand:scale-125 ease-in-out duration-300"
      >
        <path
          d="M4 13h6a1 1 0 0 0 1-1V4a1 1 0 0 0-1-1H4a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1zm-1 7a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1v-4a1 1 0 0 0-1-1H4a1 1 0 0 0-1 1v4zm10 0a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1v-7a1 1 0 0 0-1-1h-6a1 1 0 0 0-1 1v7zm1-10h6a1 1 0 0 0 1-1V4a1 1 0 0 0-1-1h-6a1 1 0 0 0-1 1v5a1 1 0 0 0 1 1z"
        ></path>
      </svg>
    </label>
    <label
      class="has-[:checked]:shadow-lg relative w-full h-16 p-4 ease-in-out duration-300 border-solid border-black/10 has-[:checked]:border group flex flex-row gap-3 items-center justify-center text-black rounded-xl"
      for="profile"
    >
      <input id="profile" name="path" type="radio" class="hidden peer/expand" />
      <svg
        viewBox="0 0 24 24"
        height="24"
        width="24"
        xmlns="http://www.w3.org/2000/svg"
        class="peer-hover/expand:scale-125 peer-hover/expand:text-blue-400 peer-hover/expand:fill-blue-400 peer-checked/expand:text-blue-400 peer-checked/expand:fill-blue-400 text-2xl peer-checked/expand:scale-125 ease-in-out duration-300"
      >
        <path
          d="M12 2a5 5 0 1 0 5 5 5 5 0 0 0-5-5zm0 8a3 3 0 1 1 3-3 3 3 0 0 1-3 3zm9 11v-1a7 7 0 0 0-7-7h-4a7 7 0 0 0-7 7v1h2v-1a5 5 0 0 1 5-5h4a5 5 0 0 1 5 5v1z"
        ></path>
      </svg>
    </label>
    <label
      class="has-[:checked]:shadow-lg relative w-full h-16 p-4 ease-in-out duration-300 border-solid border-black/10 has-[:checked]:border group flex flex-row gap-3 items-center justify-center text-black rounded-xl"
      for="messages"
    >
      <input
        id="messages"
        name="path"
        type="radio"
        class="hidden peer/expand"
      />
      <svg
        viewBox="0 0 24 24"
        height="24"
        width="24"
        xmlns="http://www.w3.org/2000/svg"
        class="peer-hover/expand:scale-125 peer-hover/expand:text-blue-400 peer-hover/expand:fill-blue-400 peer-checked/expand:text-blue-400 peer-checked/expand:fill-blue-400 text-2xl peer-checked/expand:scale-125 ease-in-out duration-300"
      >
        <path
          d="M5 18v3.766l1.515-.909L11.277 18H16c1.103 0 2-.897 2-2V8c0-1.103-.897-2-2-2H4c-1.103 0-2 .897-2 2v8c0 1.103.897 2 2 2h1zM4 8h12v8h-5.277L7 18.234V16H4V8z"
        ></path>
        <path
          d="M20 2H8c-1.103 0-2 .897-2 2h12c1.103 0 2 .897 2 2v8c1.103 0 2-.897 2-2V4c0-1.103-.897-2-2-2z"
        ></path>
      </svg>
    </label>
    <label
      class="has-[:checked]:shadow-lg relative w-full h-16 p-4 ease-in-out duration-300 border-solid border-black/10 has-[:checked]:border group flex flex-row gap-3 items-center justify-center text-black rounded-xl"
      for="help"
    >
      <input id="help" name="path" type="radio" class="hidden peer/expand" />
      <svg
        viewBox="0 0 24 24"
        height="24"
        width="24"
        xmlns="http://www.w3.org/2000/svg"
        class="peer-hover/expand:scale-125 peer-hover/expand:text-blue-400 peer-hover/expand:fill-blue-400 peer-checked/expand:text-blue-400 peer-checked/expand:fill-blue-400 text-2xl peer-checked/expand:scale-125 ease-in-out duration-300"
      >
        <path
          d="M11.953 2C6.465 2 2 6.486 2 12s4.486 10 10 10 10-4.486 10-10S17.493 2 11.953 2zM12 20c-4.411 0-8-3.589-8-8s3.567-8 7.953-8C16.391 4 20 7.589 20 12s-3.589 8-8 8z"
        ></path>
        <path d="M11 7h2v7h-2zm0 8h2v2h-2z"></path>
      </svg>
    </label>
    <label
      class="has-[:checked]:shadow-lg relative w-full h-16 p-4 ease-in-out duration-300 border-solid border-black/10 has-[:checked]:border group flex flex-row gap-3 items-center justify-center text-black rounded-xl"
      for="settings"
    >
      <input
        id="settings"
        name="path"
        type="radio"
        class="hidden peer/expand"
      />
      <svg
        viewBox="0 0 24 24"
        height="24"
        width="24"
        xmlns="http://www.w3.org/2000/svg"
        class="peer-hover/expand:scale-125 peer-hover/expand:text-blue-400 peer-hover/expand:fill-blue-400 peer-checked/expand:text-blue-400 peer-checked/expand:fill-blue-400 text-2xl peer-checked/expand:scale-125 ease-in-out duration-300"
      >
        <path
          d="M12 16c2.206 0 4-1.794 4-4s-1.794-4-4-4-4 1.794-4 4 1.794 4 4 4zm0-6c1.084 0 2 .916 2 2s-.916 2-2 2-2-.916-2-2 .916-2 2-2z"
        ></path>
        <path
          d="m2.845 16.136 1 1.73c.531.917 1.809 1.261 2.73.73l.529-.306A8.1 8.1 0 0 0 9 19.402V20c0 1.103.897 2 2 2h2c1.103 0 2-.897 2-2v-.598a8.132 8.132 0 0 0 1.896-1.111l.529.306c.923.53 2.198.188 2.731-.731l.999-1.729a2.001 2.001 0 0 0-.731-2.732l-.505-.292a7.718 7.718 0 0 0 0-2.224l.505-.292a2.002 2.002 0 0 0 .731-2.732l-.999-1.729c-.531-.92-1.808-1.265-2.731-.732l-.529.306A8.1 8.1 0 0 0 15 4.598V4c0-1.103-.897-2-2-2h-2c-1.103 0-2 .897-2 2v.598a8.132 8.132 0 0 0-1.896 1.111l-.529-.306c-.924-.531-2.2-.187-2.731.732l-.999 1.729a2.001 2.001 0 0 0 .731 2.732l.505.292a7.683 7.683 0 0 0 0 2.223l-.505.292a2.003 2.003 0 0 0-.731 2.733zm3.326-2.758A5.703 5.703 0 0 1 6 12c0-.462.058-.926.17-1.378a.999.999 0 0 0-.47-1.108l-1.123-.65.998-1.729 1.145.662a.997.997 0 0 0 1.188-.142 6.071 6.071 0 0 1 2.384-1.399A1 1 0 0 0 11 5.3V4h2v1.3a1 1 0 0 0 .708.956 6.083 6.083 0 0 1 2.384 1.399.999.999 0 0 0 1.188.142l1.144-.661 1 1.729-1.124.649a1 1 0 0 0-.47 1.108c.112.452.17.916.17 1.378 0 .461-.058.925-.171 1.378a1 1 0 0 0 .471 1.108l1.123.649-.998 1.729-1.145-.661a.996.996 0 0 0-1.188.142 6.071 6.071 0 0 1-2.384 1.399A1 1 0 0 0 13 18.7l.002 1.3H11v-1.3a1 1 0 0 0-.708-.956 6.083 6.083 0 0 1-2.384-1.399.992.992 0 0 0-1.188-.141l-1.144.662-1-1.729 1.124-.651a1 1 0 0 0 .471-1.108z"
        ></path>
      </svg>
    </label>
  </article>
</div>

<!-- Referensi Radio buttom untuk pilihan ukuran Small, Medium, Large pada detail menu -->
/* From Uiverse.io by Pradeepsaranbishnoi */ 
.container {
  display: flex;
  justify-content: center;
  align-items: center;
}

.radio-tile-group {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
}

.radio-tile-group .input-container {
  position: relative;
  height: 80px;
  width: 80px;
  margin: 0.5rem;
}

.radio-tile-group .input-container .radio-button {
  opacity: 0;
  position: absolute;
  top: 0;
  left: 0;
  height: 100%;
  width: 100%;
  margin: 0;
  cursor: pointer;
}

.radio-tile-group .input-container .radio-tile {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  border: 2px solid #079ad9;
  border-radius: 5px;
  padding: 1rem;
  transition: transform 300ms ease;
}

.radio-tile-group .input-container .icon svg {
  fill: #079ad9;
  width: 2rem;
  height: 2rem;
}

.radio-tile-group .input-container .radio-tile-label {
  text-align: center;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 1px;
  color: #079ad9;
}

.radio-tile-group .input-container .radio-button:checked + .radio-tile {
  background-color: #079ad9;
  border: 2px solid #079ad9;
  color: white;
  transform: scale(1.1, 1.1);
}

.radio-tile-group .input-container .radio-button:checked + .radio-tile .icon svg {
  fill: white;
  background-color: #079ad9;
}

.radio-tile-group .input-container .radio-button:checked + .radio-tile .radio-tile-label {
  color: white;
  background-color: #079ad9;
}

<!-- ==================== GUEST MODE ==================== -->
        <section>
            <div class="flex items-center gap-3 mb-8">
                <div class="w-12 h-12 bg-primary rounded-xl flex items-center justify-center text-white text-xl"><i class="fas fa-user"></i></div>
                <div>
                    <h2 class="text-2xl font-bold text-dark">1. Guest Mode (Tanpa Login)</h2>
                    <p class="text-gray-500">Akses terbatas dengan trigger login pada fitur tertentu</p>
                </div>
            </div>
            <div class="flex flex-wrap gap-8 justify-center">
                <!-- Splash Screen -->
                <div>
                    <div class="section-label">1A. Splash Screen</div>
                    <div class="phone-frame bg-dark flex flex-col items-center justify-center relative">
                        <div class="phone-notch"></div>
                        <div class="text-center px-8 fade-in">
                            <div class="w-24 h-24 bg-primary/20 rounded-full flex items-center justify-center mx-auto mb-6">
                                <i class="fas fa-utensils text-4xl text-primary"></i>
                            </div>
                            <h1 class="text-3xl font-bold text-white mb-2">NRelazion</h1>
                            <p class="text-gray-400 text-sm mb-8">Fine Dining Experience</p>
                            <div class="w-48 h-1 bg-gray-700 rounded-full overflow-hidden">
                                <div class="h-full bg-primary rounded-full" style="width: 70%"></div>
                            </div>
                        </div>
                        <div class="absolute bottom-8 text-gray-500 text-xs">v2.1.0</div>
                    </div>
                </div>
                <!-- Home Guest -->
                <div>
                    <div class="section-label">1B. Home (Guest)</div>
                    <div class="phone-frame bg-cream relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white shadow-sm">
                            <div class="flex justify-between items-center">
                                <div><p class="text-xs text-gray-500">Selamat datang di</p><h2 class="text-lg font-bold text-dark">NRelazion</h2></div>
                                <button class="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center text-primary"><i class="fas fa-user"></i></button>
                            </div>
                        </div>
                        <div class="h-[calc(100%-180px)] overflow-y-auto scroll-hide pb-4">
                            <div class="px-5 pt-4">
                                <div class="relative h-40 bg-gradient-to-r from-primary to-primaryDark rounded-2xl overflow-hidden">
                                    <img src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400" class="absolute inset-0 w-full h-full object-cover opacity-40">
                                    <div class="absolute inset-0 p-5 flex flex-col justify-end">
                                        <span class="text-white/80 text-xs font-medium bg-white/20 backdrop-blur px-2 py-1 rounded-full w-fit mb-2">Promo Spesial</span>
                                        <h3 class="text-white font-bold text-lg">Diskon 20%<br>Weekend Special</h3>
                                    </div>
                                    <div class="absolute bottom-4 right-4 flex gap-1">
                                        <div class="w-2 h-2 bg-white rounded-full"></div>
                                        <div class="w-2 h-2 bg-white/50 rounded-full"></div>
                                        <div class="w-2 h-2 bg-white/50 rounded-full"></div>
                                    </div>
                                </div>
                            </div>
                            <div class="px-5 pt-5">
                                <h3 class="font-bold text-dark mb-3">Kategori</h3>
                                <div class="grid grid-cols-4 gap-3">
                                    <div class="text-center"><div class="w-14 h-14 bg-orange-100 rounded-xl flex items-center justify-center mx-auto mb-1"><i class="fas fa-fire text-orange-500"></i></div><span class="text-xs text-gray-600">Hot</span></div>
                                    <div class="text-center"><div class="w-14 h-14 bg-green-100 rounded-xl flex items-center justify-center mx-auto mb-1"><i class="fas fa-leaf text-green-500"></i></div><span class="text-xs text-gray-600">Healthy</span></div>
                                    <div class="text-center"><div class="w-14 h-14 bg-blue-100 rounded-xl flex items-center justify-center mx-auto mb-1"><i class="fas fa-glass-martini text-blue-500"></i></div><span class="text-xs text-gray-600">Drinks</span></div>
                                    <div class="text-center"><div class="w-14 h-14 bg-purple-100 rounded-xl flex items-center justify-center mx-auto mb-1"><i class="fas fa-birthday-cake text-purple-500"></i></div><span class="text-xs text-gray-600">Dessert</span></div>
                                </div>
                            </div>
                            <div class="px-5 pt-5">
                                <div class="flex justify-between items-center mb-3"><h3 class="font-bold text-dark">Menu Populer</h3><span class="text-primary text-xs">Lihat Semua</span></div>
                                <div class="flex gap-3 overflow-x-auto scroll-hide pb-2">
                                    <div class="min-w-[140px] bg-white rounded-xl overflow-hidden shadow-sm">
                                        <div class="h-24 bg-gray-200 relative"><img src="https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=300" class="w-full h-full object-cover"><div class="absolute top-2 right-2 bg-white/90 backdrop-blur rounded-full w-7 h-7 flex items-center justify-center"><i class="fas fa-heart text-gray-400 text-xs"></i></div></div>
                                        <div class="p-3"><h4 class="font-semibold text-sm">Pizza Margherita</h4><p class="text-primary font-bold text-sm mt-1">Rp 85.000</p></div>
                                    </div>
                                    <div class="min-w-[140px] bg-white rounded-xl overflow-hidden shadow-sm">
                                        <div class="h-24 bg-gray-200 relative"><img src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300" class="w-full h-full object-cover"><div class="absolute top-2 right-2 bg-white/90 backdrop-blur rounded-full w-7 h-7 flex items-center justify-center"><i class="fas fa-heart text-gray-400 text-xs"></i></div></div>
                                        <div class="p-3"><h4 class="font-semibold text-sm">Salad Caesar</h4><p class="text-primary font-bold text-sm mt-1">Rp 45.000</p></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="absolute bottom-0 left-0 right-0 bg-white border-t border-gray-100 px-6 py-3 flex justify-around items-center">
                            <div class="bottom-nav-item active flex flex-col items-center gap-1"><i class="fas fa-home nav-icon text-lg"></i><span class="text-[10px]">Home</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><i class="fas fa-search nav-icon text-lg"></i><span class="text-[10px]">Cari</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><div class="relative"><i class="fas fa-shopping-cart nav-icon text-lg"></i><span class="absolute -top-1 -right-2 w-4 h-4 bg-accent text-white text-[8px] rounded-full flex items-center justify-center">0</span></div><span class="text-[10px]">Keranjang</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><i class="fas fa-user nav-icon text-lg"></i><span class="text-[10px]">Profil</span></div>
                        </div>
                    </div>
                </div>
                <!-- Menu List Guest -->
                <div>
                    <div class="section-label">1C. Daftar Menu (Read-Only)</div>
                    <div class="phone-frame bg-cream relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white">
                            <div class="flex items-center gap-3"><button class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center"><i class="fas fa-arrow-left text-sm"></i></button><h2 class="font-bold text-lg">Menu Kami</h2></div>
                            <div class="mt-3 relative"><i class="fas fa-search absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm"></i><input type="text" placeholder="Cari menu..." class="w-full bg-gray-100 rounded-xl py-2.5 pl-10 pr-4 text-sm outline-none"></div>
                            <div class="flex gap-2 mt-3 overflow-x-auto scroll-hide pb-1">
                                <span class="px-4 py-1.5 bg-primary text-white rounded-full text-xs font-medium whitespace-nowrap">Semua</span>
                                <span class="px-4 py-1.5 bg-gray-100 rounded-full text-xs font-medium whitespace-nowrap text-gray-600">Makanan</span>
                                <span class="px-4 py-1.5 bg-gray-100 rounded-full text-xs font-medium whitespace-nowrap text-gray-600">Minuman</span>
                                <span class="px-4 py-1.5 bg-gray-100 rounded-full text-xs font-medium whitespace-nowrap text-gray-600">Dessert</span>
                            </div>
                        </div>
                        <div class="h-[calc(100%-200px)] overflow-y-auto scroll-hide px-5 pt-3 space-y-3">
                            <div class="bg-white rounded-xl p-3 flex gap-3 shadow-sm card-hover">
                                <img src="https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200" class="w-20 h-20 rounded-lg object-cover">
                                <div class="flex-1"><h4 class="font-semibold text-sm">Pizza Margherita</h4><p class="text-gray-400 text-xs mt-0.5">Keju mozzarella, tomat segar</p><div class="flex justify-between items-end mt-2"><span class="text-primary font-bold text-sm">Rp 85.000</span><button class="w-7 h-7 bg-primary rounded-full flex items-center justify-center text-white text-xs"><i class="fas fa-plus"></i></button></div></div>
                            </div>
                            <div class="bg-white rounded-xl p-3 flex gap-3 shadow-sm card-hover">
                                <img src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200" class="w-20 h-20 rounded-lg object-cover">
                                <div class="flex-1"><h4 class="font-semibold text-sm">Salad Caesar</h4><p class="text-gray-400 text-xs mt-0.5">Selada romaine, crouton</p><div class="flex justify-between items-end mt-2"><span class="text-primary font-bold text-sm">Rp 45.000</span><button class="w-7 h-7 bg-primary rounded-full flex items-center justify-center text-white text-xs"><i class="fas fa-plus"></i></button></div></div>
                            </div>
                            <div class="bg-white rounded-xl p-3 flex gap-3 shadow-sm card-hover">
                                <img src="https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=200" class="w-20 h-20 rounded-lg object-cover">
                                <div class="flex-1"><h4 class="font-semibold text-sm">Pancake Stack</h4><p class="text-gray-400 text-xs mt-0.5">Maple syrup, butter</p><div class="flex justify-between items-end mt-2"><span class="text-primary font-bold text-sm">Rp 38.000</span><button class="w-7 h-7 bg-primary rounded-full flex items-center justify-center text-white text-xs"><i class="fas fa-plus"></i></button></div></div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Restaurant Info -->
                <div>
                    <div class="section-label">1D. Info Restoran</div>
                    <div class="phone-frame bg-cream relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12">
                            <div class="h-48 bg-gray-200 relative">
                                <img src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400" class="w-full h-full object-cover">
                                <div class="absolute inset-0 gradient-overlay"></div>
                                <button class="absolute top-4 left-4 w-8 h-8 bg-white/20 backdrop-blur rounded-full flex items-center justify-center text-white"><i class="fas fa-arrow-left"></i></button>
                            </div>
                            <div class="px-5 -mt-12 relative z-10">
                                <div class="bg-white rounded-2xl p-5 shadow-lg">
                                    <h2 class="font-bold text-xl">NRelazion Restaurant</h2>
                                    <div class="flex items-center gap-1 mt-1 mb-3"><i class="fas fa-star text-yellow-400 text-xs"></i><span class="text-sm font-medium">4.8</span><span class="text-gray-400 text-xs">(1.2k reviews)</span></div>
                                    <p class="text-gray-500 text-sm leading-relaxed">Restoran fine dining dengan konsep modern yang menyajikan berbagai hidangan internasional dan lokal dengan kualitas terbaik.</p>
                                    <div class="mt-4 space-y-3">
                                        <div class="flex items-center gap-3"><div class="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center text-primary"><i class="fas fa-map-marker-alt"></i></div><div><p class="text-sm font-medium">Jl. Sudirman No. 123</p><p class="text-xs text-gray-400">Jakarta Pusat</p></div></div>
                                        <div class="flex items-center gap-3"><div class="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center text-primary"><i class="fas fa-clock"></i></div><div><p class="text-sm font-medium">10:00 - 22:00 WIB</p><p class="text-xs text-green-500">Buka Sekarang</p></div></div>
                                        <div class="flex items-center gap-3"><div class="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center text-primary"><i class="fas fa-phone"></i></div><div><p class="text-sm font-medium">+62 812-3456-7890</p><p class="text-xs text-gray-400">WhatsApp/Telp</p></div></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        <!-- ==================== CUSTOMER ROLE ==================== -->
        <section>
            <div class="flex items-center gap-3 mb-8">
                <div class="w-12 h-12 bg-info rounded-xl flex items-center justify-center text-white text-xl"><i class="fas fa-user-check"></i></div>
                <div>
                    <h2 class="text-2xl font-bold text-dark">2. Role: Customer</h2>
                    <p class="text-gray-500">Autentikasi, pemesanan, riwayat, dan profil</p>
                </div>
            </div>
            <div class="flex flex-wrap gap-8 justify-center">
                <!-- Login -->
                <div>
                    <div class="section-label">2A. Login & Register</div>
                    <div class="phone-frame bg-cream relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-6 h-full flex flex-col">
                            <div class="text-center mt-8 mb-8">
                                <div class="w-20 h-20 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4"><i class="fas fa-utensils text-3xl text-primary"></i></div>
                                <h2 class="text-2xl font-bold text-dark">Selamat Datang</h2><p class="text-gray-500 text-sm mt-1">Login untuk melanjutkan</p>
                            </div>
                            <div class="space-y-4 flex-1">
                                <div><label class="text-xs font-medium text-gray-600 ml-1">Email</label><div class="mt-1 relative"><i class="fas fa-envelope absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm"></i><input type="email" value="user@email.com" class="w-full bg-white border border-gray-200 rounded-xl py-3 pl-10 pr-4 text-sm outline-none focus:border-primary"></div></div>
                                <div><label class="text-xs font-medium text-gray-600 ml-1">Password</label><div class="mt-1 relative"><i class="fas fa-lock absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm"></i><input type="password" value="********" class="w-full bg-white border border-gray-200 rounded-xl py-3 pl-10 pr-10 text-sm outline-none focus:border-primary"><i class="fas fa-eye absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm"></i></div></div>
                                <div class="flex justify-between items-center"><label class="flex items-center gap-2"><input type="checkbox" checked class="w-4 h-4 rounded border-gray-300 text-primary"><span class="text-xs text-gray-600">Ingat saya</span></label><span class="text-xs text-primary font-medium">Lupa Password?</span></div>
                                <button class="w-full bg-primary text-white py-3.5 rounded-xl font-semibold shadow-lg shadow-primary/30">Login</button>
                            </div>
                            <div class="py-6 text-center"><p class="text-sm text-gray-500">Belum punya akun? <span class="text-primary font-semibold">Daftar</span></p></div>
                        </div>
                    </div>
                </div>
                <!-- Home Customer -->
                <div>
                    <div class="section-label">2B. Home (Customer)</div>
                    <div class="phone-frame bg-cream relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white shadow-sm">
                            <div class="flex justify-between items-center">
                                <div><p class="text-xs text-gray-500">Halo, Selamat datang</p><h2 class="text-lg font-bold text-dark">John Doe</h2></div>
                                <div class="flex gap-2">
                                    <button class="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center relative"><i class="fas fa-bell text-gray-600"></i><span class="absolute top-1 right-1 w-2.5 h-2.5 bg-accent rounded-full border-2 border-white"></span></button>
                                    <div class="w-10 h-10 bg-primary rounded-full flex items-center justify-center text-white font-bold text-sm">JD</div>
                                </div>
                            </div>
                        </div>
                        <div class="h-[calc(100%-180px)] overflow-y-auto scroll-hide pb-4">
                            <div class="px-5 pt-4">
                                <div class="relative h-44 rounded-2xl overflow-hidden">
                                    <img src="https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400" class="w-full h-full object-cover">
                                    <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
                                    <div class="absolute bottom-4 left-4 right-4"><span class="bg-primary text-white text-xs px-2 py-1 rounded-md">Promo</span><h3 class="text-white font-bold mt-1">Buy 1 Get 1 Free</h3><p class="text-white/80 text-xs">Berlaku hari ini hingga 22:00</p></div>
                                </div>
                            </div>
                            <div class="px-5 pt-5">
                                <h3 class="font-bold text-dark mb-3">Kategori</h3>
                                <div class="grid grid-cols-4 gap-3">
                                    <div class="bg-white rounded-xl p-3 text-center shadow-sm"><div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center mx-auto mb-1"><i class="fas fa-drumstick-bite text-red-500 text-sm"></i></div><span class="text-[10px] text-gray-600">Main Course</span></div>
                                    <div class="bg-white rounded-xl p-3 text-center shadow-sm"><div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center mx-auto mb-1"><i class="fas fa-coffee text-blue-500 text-sm"></i></div><span class="text-[10px] text-gray-600">Beverages</span></div>
                                    <div class="bg-white rounded-xl p-3 text-center shadow-sm"><div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center mx-auto mb-1"><i class="fas fa-carrot text-green-500 text-sm"></i></div><span class="text-[10px] text-gray-600">Appetizer</span></div>
                                    <div class="bg-white rounded-xl p-3 text-center shadow-sm"><div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center mx-auto mb-1"><i class="fas fa-ice-cream text-purple-500 text-sm"></i></div><span class="text-[10px] text-gray-600">Dessert</span></div>
                                </div>
                            </div>
                            <div class="px-5 pt-5">
                                <div class="flex justify-between items-center mb-3"><h3 class="font-bold text-dark">Menu Populer</h3><span class="text-primary text-xs font-medium">Lihat Semua</span></div>
                                <div class="flex gap-3 overflow-x-auto scroll-hide pb-2">
                                    <div class="min-w-[150px] bg-white rounded-xl overflow-hidden shadow-sm">
                                        <div class="h-28 relative"><img src="https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=300" class="w-full h-full object-cover"><button class="absolute top-2 right-2 w-7 h-7 bg-white/90 rounded-full flex items-center justify-center"><i class="fas fa-heart text-accent text-xs"></i></button></div>
                                        <div class="p-3"><h4 class="font-semibold text-sm truncate">Grilled Salmon</h4><div class="flex items-center gap-1 mt-1"><i class="fas fa-star text-yellow-400 text-[10px]"></i><span class="text-xs text-gray-500">4.9</span></div><p class="text-primary font-bold text-sm mt-1">Rp 120.000</p></div>
                                    </div>
                                    <div class="min-w-[150px] bg-white rounded-xl overflow-hidden shadow-sm">
                                        <div class="h-28 relative"><img src="https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=300" class="w-full h-full object-cover"><button class="absolute top-2 right-2 w-7 h-7 bg-white/90 rounded-full flex items-center justify-center"><i class="fas fa-heart text-gray-400 text-xs"></i></button></div>
                                        <div class="p-3"><h4 class="font-semibold text-sm truncate">Beef Steak</h4><div class="flex items-center gap-1 mt-1"><i class="fas fa-star text-yellow-400 text-[10px]"></i><span class="text-xs text-gray-500">4.7</span></div><p class="text-primary font-bold text-sm mt-1">Rp 150.000</p></div>
                                    </div>
                                </div>
                            </div>
                            <div class="px-5 pt-4 pb-2">
                                <h3 class="font-bold text-dark mb-3">Rekomendasi Untukmu</h3>
                                <div class="bg-white rounded-xl p-3 flex gap-3 shadow-sm">
                                    <img src="https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=200" class="w-16 h-16 rounded-lg object-cover">
                                    <div class="flex-1"><h4 class="font-semibold text-sm">Pasta Carbonara</h4><p class="text-gray-400 text-xs">Creamy sauce with bacon</p><div class="flex justify-between items-center mt-1"><span class="text-primary font-bold text-sm">Rp 65.000</span><button class="w-6 h-6 bg-primary rounded-full flex items-center justify-center text-white text-xs"><i class="fas fa-plus"></i></button></div></div>
                                </div>
                            </div>
                        </div>
                        <div class="absolute bottom-0 left-0 right-0 bg-white border-t border-gray-100 px-6 py-3 flex justify-around items-center">
                            <div class="bottom-nav-item active flex flex-col items-center gap-1"><i class="fas fa-home nav-icon text-lg"></i><span class="text-[10px]">Home</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><i class="fas fa-search nav-icon text-lg"></i><span class="text-[10px]">Cari</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><div class="relative"><i class="fas fa-shopping-cart nav-icon text-lg"></i><span class="absolute -top-1 -right-2 w-4 h-4 bg-accent text-white text-[8px] rounded-full flex items-center justify-center">2</span></div><span class="text-[10px]">Keranjang</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><i class="fas fa-heart nav-icon text-lg"></i><span class="text-[10px]">Favorit</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><i class="fas fa-user nav-icon text-lg"></i><span class="text-[10px]">Profil</span></div>
                        </div>
                    </div>
                </div>
                <!-- Menu Detail -->
                <div>
                    <div class="section-label">2C. Detail Menu & Hero</div>
                    <div class="phone-frame bg-cream relative">
                        <div class="phone-notch"></div>
                        <div class="h-[45%] relative">
                            <img src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400" class="w-full h-full object-cover hero-img">
                            <div class="absolute top-12 left-5 right-5 flex justify-between">
                                <button class="w-10 h-10 bg-white/90 backdrop-blur rounded-full flex items-center justify-center shadow-lg"><i class="fas fa-arrow-left text-dark"></i></button>
                                <button class="w-10 h-10 bg-white/90 backdrop-blur rounded-full flex items-center justify-center shadow-lg"><i class="fas fa-heart text-accent"></i></button>
                            </div>
                            <div class="absolute bottom-0 left-0 right-0 h-20 bg-gradient-to-t from-cream to-transparent"></div>
                        </div>
                        <div class="px-6 -mt-4 relative z-10">
                            <div class="flex justify-between items-start">
                                <div><h2 class="text-2xl font-bold text-dark">Salad Caesar</h2><div class="flex items-center gap-2 mt-1"><i class="fas fa-star text-yellow-400 text-sm"></i><span class="text-sm font-medium">4.8</span><span class="text-gray-400 text-sm">(234 reviews)</span></div></div>
                                <div class="text-right"><p class="text-2xl font-bold text-primary">Rp 45.000</p><p class="text-xs text-gray-400 line-through">Rp 55.000</p></div>
                            </div>
                            <p class="text-gray-500 text-sm mt-3 leading-relaxed">Selada romaine segar dengan dressing caesar khas, ditambah crouton renyah dan parmesan cheese.</p>
                            <div class="mt-4"><h4 class="font-semibold text-sm mb-2">Tags</h4><div class="flex gap-2"><span class="px-3 py-1 bg-green-100 text-green-600 rounded-full text-xs">Healthy</span><span class="px-3 py-1 bg-orange-100 text-orange-600 rounded-full text-xs">Popular</span><span class="px-3 py-1 bg-blue-100 text-blue-600 rounded-full text-xs">Vegetarian</span></div></div>
                            <div class="mt-5"><h4 class="font-semibold text-sm mb-3">Pilih Meja</h4><div class="grid grid-cols-3 gap-2"><button class="py-2 px-3 bg-primary text-white rounded-xl text-xs font-medium">Small</button><button class="py-2 px-3 bg-white border border-gray-200 rounded-xl text-xs text-gray-600">Medium</button><button class="py-2 px-3 bg-white border border-gray-200 rounded-xl text-xs text-gray-600">Large</button></div></div>
                            <div class="mt-5"><h4 class="font-semibold text-sm mb-2">Catatan</h4><textarea placeholder="Tambahkan catatan khusus..." class="w-full bg-white border border-gray-200 rounded-xl p-3 text-sm outline-none h-20 resize-none"></textarea></div>
                        </div>
                        <div class="absolute bottom-0 left-0 right-0 bg-white border-t border-gray-100 p-5 flex gap-4">
                            <div class="flex items-center bg-gray-100 rounded-xl px-3"><button class="w-8 h-8 flex items-center justify-center text-gray-600"><i class="fas fa-minus text-xs"></i></button><span class="w-8 text-center font-semibold">1</span><button class="w-8 h-8 flex items-center justify-center text-primary"><i class="fas fa-plus text-xs"></i></button></div>
                            <button class="flex-1 bg-primary text-white py-3 rounded-xl font-semibold shadow-lg shadow-primary/30">Tambah ke Keranjang</button>
                        </div>
                    </div>
                </div>
                <!-- Cart -->
                <div>
                    <div class="section-label">2D. Keranjang & Pesan</div>
                    <div class="phone-frame bg-cream relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white">
                            <div class="flex items-center gap-3"><button class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center"><i class="fas fa-arrow-left text-sm"></i></button><h2 class="font-bold text-lg">Keranjang</h2><span class="ml-auto bg-primary/10 text-primary text-xs px-2 py-1 rounded-full">2 Items</span></div>
                        </div>
                        <div class="h-[calc(100%-280px)] overflow-y-auto scroll-hide px-5 pt-3 space-y-3">
                            <div class="bg-white rounded-xl p-4 flex gap-3 shadow-sm">
                                <img src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200" class="w-20 h-20 rounded-lg object-cover">
                                <div class="flex-1"><div class="flex justify-between"><h4 class="font-semibold text-sm">Salad Caesar</h4><button class="text-gray-400"><i class="fas fa-trash-alt text-xs"></i></button></div><p class="text-gray-400 text-xs">Meja: Lesehan | No. 5</p><div class="flex justify-between items-end mt-2"><span class="text-primary font-bold">Rp 45.000</span><div class="flex items-center bg-gray-100 rounded-lg"><button class="w-7 h-7 flex items-center justify-center text-gray-600"><i class="fas fa-minus text-xs"></i></button><span class="w-6 text-center text-sm font-medium">1</span><button class="w-7 h-7 flex items-center justify-center text-primary"><i class="fas fa-plus text-xs"></i></button></div></div></div>
                            </div>
                            <div class="bg-white rounded-xl p-4 flex gap-3 shadow-sm">
                                <img src="https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200" class="w-20 h-20 rounded-lg object-cover">
                                <div class="flex-1"><div class="flex justify-between"><h4 class="font-semibold text-sm">Pizza Margherita</h4><button class="text-gray-400"><i class="fas fa-trash-alt text-xs"></i></button></div><p class="text-gray-400 text-xs">Meja: Garden | No. 3</p><div class="flex justify-between items-end mt-2"><span class="text-primary font-bold">Rp 85.000</span><div class="flex items-center bg-gray-100 rounded-lg"><button class="w-7 h-7 flex items-center justify-center text-gray-600"><i class="fas fa-minus text-xs"></i></button><span class="w-6 text-center text-sm font-medium">1</span><button class="w-7 h-7 flex items-center justify-center text-primary"><i class="fas fa-plus text-xs"></i></button></div></div></div>
                            </div>
                        </div>
                        <div class="absolute bottom-0 left-0 right-0 bg-white border-t border-gray-100 p-5">
                            <div class="mb-3"><h4 class="font-semibold text-sm mb-2">Metode Pembayaran</h4><div class="flex gap-2"><button class="flex-1 py-2 bg-primary text-white rounded-xl text-xs font-medium flex items-center justify-center gap-2"><i class="fas fa-money-bill-wave"></i> Tunai</button><button class="flex-1 py-2 bg-gray-100 text-gray-600 rounded-xl text-xs font-medium flex items-center justify-center gap-2"><i class="fas fa-qrcode"></i> QRIS</button></div></div>
                            <div class="flex justify-between text-sm mb-1"><span class="text-gray-500">Subtotal</span><span class="font-medium">Rp 130.000</span></div>
                            <div class="flex justify-between text-sm mb-3"><span class="text-gray-500">Pajak (10%)</span><span class="font-medium">Rp 13.000</span></div>
                            <div class="flex justify-between items-center mb-4"><span class="font-bold">Total</span><span class="font-bold text-xl text-primary">Rp 143.000</span></div>
                            <button class="w-full bg-primary text-white py-3.5 rounded-xl font-semibold shadow-lg shadow-primary/30">Pesan Sekarang</button>
                        </div>
                    </div>
                </div>
                <!-- History Timeline -->
                <div>
                    <div class="section-label">2E. Riwayat & Timeline</div>
                    <div class="phone-frame bg-cream relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white">
                            <div class="flex items-center gap-3"><button class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center"><i class="fas fa-arrow-left text-sm"></i></button><h2 class="font-bold text-lg">Riwayat Pesanan</h2></div>
                        </div>
                        <div class="h-[calc(100%-140px)] overflow-y-auto scroll-hide px-5 pt-3 space-y-4">
                            <div class="bg-white rounded-xl p-4 shadow-sm border-l-4 border-warning">
                                <div class="flex justify-between items-start mb-3"><div><p class="text-xs text-gray-400">Order #NR-2024-001</p><p class="text-xs text-gray-400">10 Mei 2024, 14:30</p></div><span class="px-2 py-1 bg-warning/10 text-warning text-xs rounded-full font-medium">Diproses</span></div>
                                <div class="space-y-2 mb-3"><div class="flex justify-between text-sm"><span>Salad Caesar (1x)</span><span>Rp 45.000</span></div><div class="flex justify-between text-sm"><span>Pizza Margherita (1x)</span><span>Rp 85.000</span></div></div>
                                <div class="border-t pt-3"><p class="text-sm font-bold text-right">Total: Rp 143.000</p></div>
                                <div class="mt-4 relative pl-8">
                                    <div class="timeline-line"></div>
                                    <div class="flex items-center gap-3 mb-4"><div class="timeline-dot bg-success text-white absolute left-0"><i class="fas fa-check"></i></div><div><p class="text-sm font-medium">Pesanan Diterima</p><p class="text-xs text-gray-400">14:30</p></div></div>
                                    <div class="flex items-center gap-3 mb-4"><div class="timeline-dot bg-success text-white absolute left-0"><i class="fas fa-check"></i></div><div><p class="text-sm font-medium">Dikonfirmasi</p><p class="text-xs text-gray-400">14:32</p></div></div>
                                    <div class="flex items-center gap-3"><div class="timeline-dot bg-warning text-white absolute left-0 pulse-dot"><i class="fas fa-clock"></i></div><div><p class="text-sm font-medium">Sedang Diproses</p><p class="text-xs text-gray-400">14:35 - Sekarang</p></div></div>
                                </div>
                            </div>
                            <div class="bg-white rounded-xl p-4 shadow-sm">
                                <div class="flex justify-between items-start mb-3"><div><p class="text-xs text-gray-400">Order #NR-2024-000</p><p class="text-xs text-gray-400">8 Mei 2024, 19:15</p></div><span class="px-2 py-1 bg-success/10 text-success text-xs rounded-full font-medium">Selesai</span></div>
                                <div class="flex justify-between text-sm mb-3"><span>Beef Steak (2x)</span><span>Rp 300.000</span></div>
                                <div class="flex gap-2"><button class="flex-1 py-2 bg-primary text-white rounded-xl text-xs font-medium">Pesan Lagi</button><button class="flex-1 py-2 bg-gray-100 text-gray-600 rounded-xl text-xs font-medium">Detail</button></div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Favorites -->
                <div>
                    <div class="section-label">2F. Favorit</div>
                    <div class="phone-frame bg-cream relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white"><h2 class="font-bold text-lg">Menu Favorit</h2><p class="text-gray-400 text-xs">12 item tersimpan</p></div>
                        <div class="h-[calc(100%-140px)] overflow-y-auto scroll-hide px-5 pt-3 space-y-3">
                            <div class="bg-white rounded-xl overflow-hidden shadow-sm flex">
                                <img src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200" class="w-28 h-28 object-cover">
                                <div class="flex-1 p-3 flex flex-col justify-between"><div><div class="flex justify-between"><h4 class="font-semibold text-sm">Salad Caesar</h4><button class="text-accent"><i class="fas fa-heart"></i></button></div><p class="text-gray-400 text-xs">Healthy • Vegetarian</p></div><div class="flex justify-between items-center"><span class="text-primary font-bold">Rp 45.000</span><button class="px-3 py-1.5 bg-primary text-white rounded-lg text-xs">+ Keranjang</button></div></div>
                            </div>
                            <div class="bg-white rounded-xl overflow-hidden shadow-sm flex">
                                <img src="https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200" class="w-28 h-28 object-cover">
                                <div class="flex-1 p-3 flex flex-col justify-between"><div><div class="flex justify-between"><h4 class="font-semibold text-sm">Pizza Margherita</h4><button class="text-accent"><i class="fas fa-heart"></i></button></div><p class="text-gray-400 text-xs">Italian • Popular</p></div><div class="flex justify-between items-center"><span class="text-primary font-bold">Rp 85.000</span><button class="px-3 py-1.5 bg-primary text-white rounded-lg text-xs">+ Keranjang</button></div></div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Profile -->
                <div>
                    <div class="section-label">2G. Profil</div>
                    <div class="phone-frame bg-cream relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12">
                            <div class="bg-primary h-32 relative">
                                <div class="absolute -bottom-12 left-1/2 -translate-x-1/2"><div class="w-24 h-24 bg-white rounded-full p-1"><div class="w-full h-full bg-primary rounded-full flex items-center justify-center text-white text-2xl font-bold">JD</div></div></div>
                            </div>
                            <div class="pt-16 px-6 text-center"><h2 class="font-bold text-xl">John Doe</h2><p class="text-gray-400 text-sm">john.doe@email.com</p><p class="text-gray-400 text-sm">+62 812-3456-7890</p></div>
                            <div class="px-6 mt-6 space-y-2">
                                <div class="bg-white rounded-xl p-4 flex items-center gap-3 shadow-sm"><div class="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center text-primary"><i class="fas fa-user-edit"></i></div><div class="flex-1"><p class="font-medium text-sm">Edit Profil</p></div><i class="fas fa-chevron-right text-gray-400 text-xs"></i></div>
                                <div class="bg-white rounded-xl p-4 flex items-center gap-3 shadow-sm"><div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center text-blue-500"><i class="fas fa-key"></i></div><div class="flex-1"><p class="font-medium text-sm">Ubah Password</p></div><i class="fas fa-chevron-right text-gray-400 text-xs"></i></div>
                                <div class="bg-white rounded-xl p-4 flex items-center gap-3 shadow-sm"><div class="w-10 h-10 bg-purple-100 rounded-full flex items-center justify-center text-purple-500"><i class="fas fa-map-marker-alt"></i></div><div class="flex-1"><p class="font-medium text-sm">Alamat Tersimpan</p></div><i class="fas fa-chevron-right text-gray-400 text-xs"></i></div>
                                <div class="bg-white rounded-xl p-4 flex items-center gap-3 shadow-sm"><div class="w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center text-orange-500"><i class="fas fa-question-circle"></i></div><div class="flex-1"><p class="font-medium text-sm">Bantuan</p></div><i class="fas fa-chevron-right text-gray-400 text-xs"></i></div>
                            </div>
                            <div class="px-6 mt-6 pb-8"><button class="w-full bg-red-50 text-red-500 py-3 rounded-xl font-medium flex items-center justify-center gap-2"><i class="fas fa-sign-out-alt"></i> Logout</button></div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        <!-- ==================== KASIR ROLE ==================== -->
        <section>
            <div class="flex items-center gap-3 mb-8">
                <div class="w-12 h-12 bg-warning rounded-xl flex items-center justify-center text-white text-xl"><i class="fas fa-cash-register"></i></div>
                <div>
                    <h2 class="text-2xl font-bold text-dark">3. Role: Kasir</h2>
                    <p class="text-gray-500">Dashboard, manajemen pesanan, pembayaran & meja</p>
                </div>
            </div>
            <div class="flex flex-wrap gap-8 justify-center">
                <!-- Kasir Dashboard -->
                <div>
                    <div class="section-label">3A. Dashboard Kasir</div>
                    <div class="phone-frame bg-gray-50 relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-secondary">
                            <div class="flex justify-between items-center text-white">
                                <div><p class="text-xs text-gray-400">Selamat datang</p><h2 class="text-lg font-bold">Kasir NRelazio</h2></div>
                                <div class="relative"><i class="fas fa-bell text-lg"></i><span class="absolute -top-1 -right-1 w-4 h-4 bg-accent rounded-full text-white text-[8px] flex items-center justify-center font-bold">3</span></div>
                            </div>
                        </div>
                        <div class="h-[calc(100%-200px)] overflow-y-auto scroll-hide px-5 pt-4 space-y-4">
                            <div class="grid grid-cols-2 gap-3">
                                <div class="bg-white rounded-xl p-4 shadow-sm"><div class="w-8 h-8 bg-primary/10 rounded-lg flex items-center justify-center text-primary mb-2"><i class="fas fa-wallet text-sm"></i></div><p class="text-xs text-gray-500">Pendapatan Hari Ini</p><p class="text-lg font-bold text-dark">Rp 2.4jt</p></div>
                                <div class="bg-white rounded-xl p-4 shadow-sm"><div class="w-8 h-8 bg-info/10 rounded-lg flex items-center justify-center text-info mb-2"><i class="fas fa-receipt text-sm"></i></div><p class="text-xs text-gray-500">Total Pesanan</p><p class="text-lg font-bold text-dark">24 Order</p></div>
                            </div>
                            <div class="bg-accent/10 border border-accent/20 rounded-xl p-4 flex items-center gap-3">
                                <div class="w-10 h-10 bg-accent rounded-full flex items-center justify-center text-white"><i class="fas fa-exclamation"></i></div>
                                <div class="flex-1"><p class="font-semibold text-sm text-accent">3 Pesanan Menunggu</p><p class="text-xs text-gray-500">Perlu konfirmasi segera</p></div>
                                <i class="fas fa-chevron-right text-accent"></i>
                            </div>
                            <div>
                                <h3 class="font-bold text-dark mb-3">Pesanan Terbaru</h3>
                                <div class="space-y-2">
                                    <div class="bg-white rounded-xl p-3 flex items-center gap-3 shadow-sm"><div class="w-10 h-10 bg-warning/10 rounded-full flex items-center justify-center text-warning"><i class="fas fa-clock text-xs"></i></div><div class="flex-1"><p class="text-sm font-medium">Order #NR-2024-005</p><p class="text-xs text-gray-400">Meja VIP-2 • Rp 320.000</p></div><span class="px-2 py-1 bg-warning/10 text-warning text-xs rounded-full">Menunggu</span></div>
                                    <div class="bg-white rounded-xl p-3 flex items-center gap-3 shadow-sm"><div class="w-10 h-10 bg-success/10 rounded-full flex items-center justify-center text-success"><i class="fas fa-check text-xs"></i></div><div class="flex-1"><p class="text-sm font-medium">Order #NR-2024-004</p><p class="text-xs text-gray-400">Meja L-5 • Rp 145.000</p></div><span class="px-2 py-1 bg-success/10 text-success text-xs rounded-full">Selesai</span></div>
                                </div>
                            </div>
                        </div>
                        <div class="absolute bottom-0 left-0 right-0 bg-white border-t border-gray-100 px-6 py-3 flex justify-around items-center">
                            <div class="bottom-nav-item active flex flex-col items-center gap-1 text-primary"><i class="fas fa-home nav-icon text-lg"></i><span class="text-[10px]">Home</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><i class="fas fa-receipt nav-icon text-lg"></i><span class="text-[10px]">Pesanan</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><i class="fas fa-chair nav-icon text-lg"></i><span class="text-[10px]">Meja</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><i class="fas fa-user nav-icon text-lg"></i><span class="text-[10px]">Profil</span></div>
                        </div>
                    </div>
                </div>
                <!-- Order Management -->
                <div>
                    <div class="section-label">3B. Manajemen Pesanan</div>
                    <div class="phone-frame bg-gray-50 relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white">
                            <div class="flex items-center gap-3"><button class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center"><i class="fas fa-arrow-left text-sm"></i></button><h2 class="font-bold text-lg">Pesanan</h2></div>
                            <div class="flex gap-2 mt-3 overflow-x-auto scroll-hide pb-1">
                                <span class="px-4 py-1.5 bg-primary text-white rounded-full text-xs font-medium whitespace-nowrap">Semua (12)</span>
                                <span class="px-4 py-1.5 bg-gray-100 rounded-full text-xs font-medium whitespace-nowrap text-gray-600">Menunggu (3)</span>
                                <span class="px-4 py-1.5 bg-gray-100 rounded-full text-xs font-medium whitespace-nowrap text-gray-600">Proses (5)</span>
                                <span class="px-4 py-1.5 bg-gray-100 rounded-full text-xs font-medium whitespace-nowrap text-gray-600">Selesai (4)</span>
                            </div>
                        </div>
                        <div class="h-[calc(100%-200px)] overflow-y-auto scroll-hide px-5 pt-3 space-y-3">
                            <div class="bg-white rounded-xl p-4 shadow-sm">
                                <div class="flex justify-between items-start mb-2"><div><p class="text-sm font-bold">Order #NR-2024-005</p><p class="text-xs text-gray-400">John Doe • Meja VIP-2</p></div><span class="px-2 py-1 bg-warning/10 text-warning text-xs rounded-full">Menunggu</span></div>
                                <div class="space-y-1 mb-3"><p class="text-xs text-gray-600">• Beef Steak x2</p><p class="text-xs text-gray-600">• Salad Caesar x1</p></div>
                                <div class="flex justify-between items-center border-t pt-3"><span class="font-bold text-sm">Rp 320.000</span><div class="flex gap-2"><button class="px-3 py-1.5 bg-success text-white rounded-lg text-xs">Konfirmasi</button><button class="px-3 py-1.5 bg-gray-100 text-gray-600 rounded-lg text-xs">Detail</button></div></div>
                            </div>
                            <div class="bg-white rounded-xl p-4 shadow-sm">
                                <div class="flex justify-between items-start mb-2"><div><p class="text-sm font-bold">Order #NR-2024-003</p><p class="text-xs text-gray-400">Jane Smith • Meja Garden-1</p></div><span class="px-2 py-1 bg-info/10 text-info text-xs rounded-full">Diproses</span></div>
                                <div class="space-y-1 mb-3"><p class="text-xs text-gray-600">• Pizza Margherita x1</p><p class="text-xs text-gray-600">• Iced Coffee x2</p></div>
                                <div class="flex justify-between items-center border-t pt-3"><span class="font-bold text-sm">Rp 145.000</span><div class="flex gap-2"><button class="px-3 py-1.5 bg-primary text-white rounded-lg text-xs">Siap</button><button class="px-3 py-1.5 bg-gray-100 text-gray-600 rounded-lg text-xs">Detail</button></div></div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Payment System -->
                <div>
                    <div class="section-label">3C. Sistem Pembayaran</div>
                    <div class="phone-frame bg-gray-50 relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white">
                            <div class="flex items-center gap-3"><button class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center"><i class="fas fa-arrow-left text-sm"></i></button><h2 class="font-bold text-lg">Pembayaran</h2></div>
                        </div>
                        <div class="h-[calc(100%-200px)] overflow-y-auto scroll-hide px-5 pt-3">
                            <div class="bg-white rounded-xl p-4 shadow-sm mb-4">
                                <p class="text-xs text-gray-400 mb-1">Order #NR-2024-005</p>
                                <p class="text-sm font-bold">John Doe • Meja VIP-2</p>
                                <div class="mt-3 space-y-2"><div class="flex justify-between text-sm"><span>Beef Steak (2x)</span><span>Rp 300.000</span></div><div class="flex justify-between text-sm"><span>Salad Caesar (1x)</span><span>Rp 45.000</span></div><div class="border-t pt-2 flex justify-between font-bold"><span>Total</span><span>Rp 345.000</span></div></div>
                            </div>
                            <div class="mb-4">
                                <h4 class="font-semibold text-sm mb-2">Metode Pembayaran</h4>
                                <div class="flex gap-2">
                                    <button class="flex-1 py-3 bg-primary text-white rounded-xl text-xs font-medium flex items-center justify-center gap-2"><i class="fas fa-money-bill-wave"></i> Tunai</button>
                                    <button class="flex-1 py-3 bg-white border border-gray-200 text-gray-600 rounded-xl text-xs font-medium flex items-center justify-center gap-2"><i class="fas fa-qrcode"></i> QRIS</button>
                                </div>
                            </div>
                            <div class="bg-white rounded-xl p-4 shadow-sm mb-4">
                                <h4 class="font-semibold text-sm mb-3">Kalkulator Kembalian</h4>
                                <div class="space-y-3">
                                    <div><label class="text-xs text-gray-500">Total Bayar</label><p class="text-xl font-bold text-dark">Rp 345.000</p></div>
                                    <div><label class="text-xs text-gray-500">Uang Diterima</label><input type="number" value="400000" class="w-full bg-gray-100 rounded-xl py-2 px-3 text-sm mt-1 outline-none"></div>
                                    <div class="bg-success/10 rounded-lg p-3"><div class="flex justify-between items-center"><span class="text-sm font-medium text-success">Kembalian</span><span class="text-lg font-bold text-success">Rp 55.000</span></div></div>
                                </div>
                            </div>
                            <button class="w-full bg-success text-white py-3.5 rounded-xl font-semibold shadow-lg shadow-success/30 mb-4"><i class="fas fa-check-circle mr-2"></i>Bayar & Selesaikan</button>
                        </div>
                    </div>
                </div>
                <!-- Table Management -->
                <div>
                    <div class="section-label">3D. Manajemen Meja</div>
                    <div class="phone-frame bg-gray-50 relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white">
                            <div class="flex items-center gap-3"><button class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center"><i class="fas fa-arrow-left text-sm"></i></button><h2 class="font-bold text-lg">Manajemen Meja</h2></div>
                            <div class="flex gap-3 mt-3">
                                <div class="flex items-center gap-1"><div class="w-3 h-3 bg-success rounded-full"></div><span class="text-xs text-gray-600">Kosong</span></div>
                                <div class="flex items-center gap-1"><div class="w-3 h-3 bg-accent rounded-full"></div><span class="text-xs text-gray-600">Terisi</span></div>
                                <div class="flex items-center gap-1"><div class="w-3 h-3 bg-warning rounded-full"></div><span class="text-xs text-gray-600">Reserved</span></div>
                            </div>
                        </div>
                        <div class="h-[calc(100%-200px)] overflow-y-auto scroll-hide px-5 pt-3">
                            <div class="mb-3"><h4 class="font-semibold text-sm">Area Lesehan</h4></div>
                            <div class="grid grid-cols-3 gap-3 mb-5">
                                <div class="table-card bg-success/10 border-2 border-success rounded-xl p-3 text-center cursor-pointer"><i class="fas fa-chair text-success text-xl mb-1"></i><p class="text-xs font-bold">L-1</p><p class="text-[10px] text-success">Kosong</p></div>
                                <div class="table-card bg-accent/10 border-2 border-accent rounded-xl p-3 text-center cursor-pointer"><i class="fas fa-chair text-accent text-xl mb-1"></i><p class="text-xs font-bold">L-2</p><p class="text-[10px] text-accent">John D.</p></div>
                                <div class="table-card bg-success/10 border-2 border-success rounded-xl p-3 text-center cursor-pointer"><i class="fas fa-chair text-success text-xl mb-1"></i><p class="text-xs font-bold">L-3</p><p class="text-[10px] text-success">Kosong</p></div>
                                <div class="table-card bg-warning/10 border-2 border-warning rounded-xl p-3 text-center cursor-pointer"><i class="fas fa-chair text-warning text-xl mb-1"></i><p class="text-xs font-bold">L-4</p><p class="text-[10px] text-warning">Reserved</p></div>
                                <div class="table-card bg-success/10 border-2 border-success rounded-xl p-3 text-center cursor-pointer"><i class="fas fa-chair text-success text-xl mb-1"></i><p class="text-xs font-bold">L-5</p><p class="text-[10px] text-success">Kosong</p></div>
                                <div class="table-card bg-accent/10 border-2 border-accent rounded-xl p-3 text-center cursor-pointer"><i class="fas fa-chair text-accent text-xl mb-1"></i><p class="text-xs font-bold">L-6</p><p class="text-[10px] text-accent">Jane S.</p></div>
                            </div>
                            <div class="mb-3"><h4 class="font-semibold text-sm">Area VIP</h4></div>
                            <div class="grid grid-cols-2 gap-3">
                                <div class="table-card bg-accent/10 border-2 border-accent rounded-xl p-4 text-center cursor-pointer"><i class="fas fa-crown text-accent text-2xl mb-2"></i><p class="text-sm font-bold">VIP-1</p><p class="text-xs text-accent">Ahmad R. • 4 Orang</p></div>
                                <div class="table-card bg-success/10 border-2 border-success rounded-xl p-4 text-center cursor-pointer"><i class="fas fa-crown text-success text-2xl mb-2"></i><p class="text-sm font-bold">VIP-2</p><p class="text-xs text-success">Kosong</p></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        <!-- ==================== ADMIN ROLE ==================== -->
        <section>
            <div class="flex items-center gap-3 mb-8">
                <div class="w-12 h-12 bg-success rounded-xl flex items-center justify-center text-white text-xl"><i class="fas fa-shield-alt"></i></div>
                <div>
                    <h2 class="text-2xl font-bold text-dark">4. Role: Admin</h2>
                    <p class="text-gray-500">CRUD data, analitik, laporan & pengaturan aplikasi</p>
                </div>
            </div>
            <div class="flex flex-wrap gap-8 justify-center">
                <!-- Admin Dashboard -->
                <div>
                    <div class="section-label">4A. Dashboard Admin</div>
                    <div class="phone-frame bg-gray-50 relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-secondary">
                            <div class="flex justify-between items-center text-white">
                                <div><p class="text-xs text-gray-400">Dashboard</p><h2 class="text-lg font-bold">Admin Panel</h2></div>
                                <div class="w-10 h-10 bg-white/10 rounded-full flex items-center justify-center"><i class="fas fa-cog text-white"></i></div>
                            </div>
                        </div>
                        <div class="h-[calc(100%-200px)] overflow-y-auto scroll-hide px-5 pt-4 space-y-4">
                            <div class="grid grid-cols-2 gap-3">
                                <div class="bg-white rounded-xl p-4 shadow-sm"><div class="w-8 h-8 bg-primary/10 rounded-lg flex items-center justify-center text-primary mb-2"><i class="fas fa-wallet text-sm"></i></div><p class="text-xs text-gray-500">Pendapatan Bulan Ini</p><p class="text-lg font-bold text-dark">Rp 45.2jt</p></div>
                                <div class="bg-white rounded-xl p-4 shadow-sm"><div class="w-8 h-8 bg-success/10 rounded-lg flex items-center justify-center text-success mb-2"><i class="fas fa-users text-sm"></i></div><p class="text-xs text-gray-500">Total Pelanggan</p><p class="text-lg font-bold text-dark">1,248</p></div>
                            </div>
                            <div class="bg-white rounded-xl p-4 shadow-sm">
                                <div class="flex justify-between items-center mb-3"><h4 class="font-semibold text-sm">Tren Pendapatan 7 Hari</h4><span class="text-xs text-primary">Lihat Detail</span></div>
                                <div class="mock-chart">
                                    <div class="mock-bar" style="height: 40%"></div>
                                    <div class="mock-bar" style="height: 65%"></div>
                                    <div class="mock-bar" style="height: 85%"></div>
                                    <div class="mock-bar" style="height: 55%"></div>
                                    <div class="mock-bar" style="height: 70%"></div>
                                    <div class="mock-bar" style="height: 90%"></div>
                                    <div class="mock-bar" style="height: 75%"></div>
                                </div>
                                <div class="flex justify-between mt-2 text-[10px] text-gray-400"><span>Sen</span><span>Sel</span><span>Rab</span><span>Kam</span><span>Jum</span><span>Sab</span><span>Min</span></div>
                            </div>
                            <div>
                                <h4 class="font-semibold text-sm mb-3">Menu Terlaris</h4>
                                <div class="space-y-2">
                                    <div class="bg-white rounded-xl p-3 flex items-center gap-3 shadow-sm">
                                        <div class="w-8 h-8 bg-yellow-100 rounded-full flex items-center justify-center text-yellow-600 font-bold text-xs">1</div>
                                        <img src="https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=100" class="w-10 h-10 rounded-lg object-cover">
                                        <div class="flex-1"><p class="text-sm font-medium">Pizza Margherita</p><p class="text-xs text-gray-400">124 terjual</p></div>
                                        <span class="text-sm font-bold text-primary">Rp 10.5jt</span>
                                    </div>
                                    <div class="bg-white rounded-xl p-3 flex items-center gap-3 shadow-sm">
                                        <div class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center text-gray-600 font-bold text-xs">2</div>
                                        <img src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100" class="w-10 h-10 rounded-lg object-cover">
                                        <div class="flex-1"><p class="text-sm font-medium">Salad Caesar</p><p class="text-xs text-gray-400">98 terjual</p></div>
                                        <span class="text-sm font-bold text-primary">Rp 4.4jt</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="absolute bottom-0 left-0 right-0 bg-white border-t border-gray-100 px-6 py-3 flex justify-around items-center">
                            <div class="bottom-nav-item active flex flex-col items-center gap-1 text-primary"><i class="fas fa-chart-line nav-icon text-lg"></i><span class="text-[10px]">Dashboard</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><i class="fas fa-utensils nav-icon text-lg"></i><span class="text-[10px]">Menu</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><i class="fas fa-file-alt nav-icon text-lg"></i><span class="text-[10px]">Laporan</span></div>
                            <div class="bottom-nav-item flex flex-col items-center gap-1 text-gray-400"><i class="fas fa-cog nav-icon text-lg"></i><span class="text-[10px]">Setting</span></div>
                        </div>
                    </div>
                </div>
                <!-- Menu CRUD -->
                <div>
                    <div class="section-label">4B. Manajemen Menu (CRUD)</div>
                    <div class="phone-frame bg-gray-50 relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white">
                            <div class="flex justify-between items-center"><h2 class="font-bold text-lg">Kelola Menu</h2><button class="w-8 h-8 bg-primary rounded-full flex items-center justify-center text-white"><i class="fas fa-plus text-sm"></i></button></div>
                            <div class="flex gap-2 mt-3 overflow-x-auto scroll-hide pb-1">
                                <span class="px-4 py-1.5 bg-primary text-white rounded-full text-xs font-medium whitespace-nowrap">Semua (24)</span>
                                <span class="px-4 py-1.5 bg-gray-100 rounded-full text-xs font-medium whitespace-nowrap text-gray-600">Aktif (20)</span>
                                <span class="px-4 py-1.5 bg-gray-100 rounded-full text-xs font-medium whitespace-nowrap text-gray-600">Nonaktif (4)</span>
                            </div>
                        </div>
                        <div class="h-[calc(100%-200px)] overflow-y-auto scroll-hide px-5 pt-3 space-y-3">
                            <div class="bg-white rounded-xl p-3 flex gap-3 shadow-sm">
                                <img src="https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200" class="w-16 h-16 rounded-lg object-cover">
                                <div class="flex-1"><div class="flex justify-between"><h4 class="font-semibold text-sm">Pizza Margherita</h4><div class="flex gap-2"><button class="text-info"><i class="fas fa-edit text-xs"></i></button><button class="text-accent"><i class="fas fa-trash text-xs"></i></button></div></div><p class="text-xs text-gray-400">Main Course • Rp 85.000</p><div class="flex items-center gap-2 mt-1"><span class="px-2 py-0.5 bg-green-100 text-green-600 rounded text-[10px]">Aktif</span><span class="text-[10px] text-gray-400">124 terjual</span></div></div>
                            </div>
                            <div class="bg-white rounded-xl p-3 flex gap-3 shadow-sm">
                                <img src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200" class="w-16 h-16 rounded-lg object-cover">
                                <div class="flex-1"><div class="flex justify-between"><h4 class="font-semibold text-sm">Salad Caesar</h4><div class="flex gap-2"><button class="text-info"><i class="fas fa-edit text-xs"></i></button><button class="text-accent"><i class="fas fa-trash text-xs"></i></button></div></div><p class="text-xs text-gray-400">Appetizer • Rp 45.000</p><div class="flex items-center gap-2 mt-1"><span class="px-2 py-0.5 bg-green-100 text-green-600 rounded text-[10px]">Aktif</span><span class="text-[10px] text-gray-400">98 terjual</span></div></div>
                            </div>
                            <div class="bg-white rounded-xl p-3 flex gap-3 shadow-sm">
                                <div class="w-16 h-16 bg-gray-200 rounded-lg flex items-center justify-center"><i class="fas fa-image text-gray-400"></i></div>
                                <div class="flex-1"><div class="flex justify-between"><h4 class="font-semibold text-sm">Seasonal Soup</h4><div class="flex gap-2"><button class="text-info"><i class="fas fa-edit text-xs"></i></button><button class="text-accent"><i class="fas fa-trash text-xs"></i></button></div></div><p class="text-xs text-gray-400">Appetizer • Rp 35.000</p><div class="flex items-center gap-2 mt-1"><span class="px-2 py-0.5 bg-gray-100 text-gray-500 rounded text-[10px]">Nonaktif</span><span class="text-[10px] text-gray-400">0 terjual</span></div></div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Add/Edit Menu -->
                <div>
                    <div class="section-label">4C. Tambah/Edit Menu</div>
                    <div class="phone-frame bg-gray-50 relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white">
                            <div class="flex items-center gap-3"><button class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center"><i class="fas fa-arrow-left text-sm"></i></button><h2 class="font-bold text-lg">Tambah Menu</h2></div>
                        </div>
                        <div class="h-[calc(100%-140px)] overflow-y-auto scroll-hide px-5 pt-3 space-y-4">
                            <div class="bg-white rounded-xl p-4 shadow-sm">
                                <div class="w-full h-32 bg-gray-100 rounded-xl flex flex-col items-center justify-center gap-2 mb-3">
                                    <i class="fas fa-cloud-upload-alt text-3xl text-gray-400"></i>
                                    <p class="text-xs text-gray-500">Upload gambar ke Google Drive</p>
                                </div>
                                <div class="space-y-3">
                                    <div><label class="text-xs font-medium text-gray-600">Nama Menu</label><input type="text" value="Pizza Margherita" class="w-full bg-gray-100 rounded-xl py-2.5 px-3 text-sm mt-1 outline-none"></div>
                                    <div><label class="text-xs font-medium text-gray-600">Kategori</label><select class="w-full bg-gray-100 rounded-xl py-2.5 px-3 text-sm mt-1 outline-none"><option>Main Course</option><option>Appetizer</option><option>Beverages</option><option>Dessert</option></select></div>
                                    <div class="grid grid-cols-2 gap-3">
                                        <div><label class="text-xs font-medium text-gray-600">Harga</label><input type="number" value="85000" class="w-full bg-gray-100 rounded-xl py-2.5 px-3 text-sm mt-1 outline-none"></div>
                                        <div><label class="text-xs font-medium text-gray-600">Stok</label><input type="number" value="50" class="w-full bg-gray-100 rounded-xl py-2.5 px-3 text-sm mt-1 outline-none"></div>
                                    </div>
                                    <div><label class="text-xs font-medium text-gray-600">Deskripsi</label><textarea class="w-full bg-gray-100 rounded-xl py-2.5 px-3 text-sm mt-1 outline-none h-20 resize-none">Keju mozzarella, tomat segar, basil</textarea></div>
                                    <div class="flex items-center justify-between"><span class="text-sm font-medium">Status Aktif</span><div class="w-11 h-6 bg-primary rounded-full relative"><div class="absolute right-1 top-1 w-4 h-4 bg-white rounded-full"></div></div></div>
                                </div>
                            </div>
                            <button class="w-full bg-primary text-white py-3 rounded-xl font-semibold shadow-lg shadow-primary/30">Simpan Menu</button>
                        </div>
                    </div>
                </div>
                <!-- Table Management Admin -->
                <div>
                    <div class="section-label">4D. Kelola Meja & Area</div>
                    <div class="phone-frame bg-gray-50 relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white">
                            <div class="flex justify-between items-center"><h2 class="font-bold text-lg">Kelola Meja</h2><button class="w-8 h-8 bg-primary rounded-full flex items-center justify-center text-white"><i class="fas fa-plus text-sm"></i></button></div>
                        </div>
                        <div class="h-[calc(100%-140px)] overflow-y-auto scroll-hide px-5 pt-3 space-y-4">
                            <div class="bg-white rounded-xl p-4 shadow-sm">
                                <div class="flex justify-between items-center mb-3"><h4 class="font-semibold text-sm">Area Lesehan</h4><span class="text-xs text-primary">Edit Area</span></div>
                                <div class="grid grid-cols-3 gap-2">
                                    <div class="bg-success/10 border border-success rounded-lg p-2 text-center"><p class="text-xs font-bold">L-1</p><p class="text-[10px] text-gray-500">4 kursi</p></div>
                                    <div class="bg-success/10 border border-success rounded-lg p-2 text-center"><p class="text-xs font-bold">L-2</p><p class="text-[10px] text-gray-500">4 kursi</p></div>
                                    <div class="bg-success/10 border border-success rounded-lg p-2 text-center"><p class="text-xs font-bold">L-3</p><p class="text-[10px] text-gray-500">6 kursi</p></div>
                                    <div class="bg-success/10 border border-success rounded-lg p-2 text-center"><p class="text-xs font-bold">L-4</p><p class="text-[10px] text-gray-500">4 kursi</p></div>
                                    <div class="bg-success/10 border border-success rounded-lg p-2 text-center"><p class="text-xs font-bold">L-5</p><p class="text-[10px] text-gray-500">2 kursi</p></div>
                                    <div class="bg-success/10 border border-success rounded-lg p-2 text-center"><p class="text-xs font-bold">L-6</p><p class="text-[10px] text-gray-500">4 kursi</p></div>
                                </div>
                            </div>
                            <div class="bg-white rounded-xl p-4 shadow-sm">
                                <div class="flex justify-between items-center mb-3"><h4 class="font-semibold text-sm">Area VIP</h4><span class="text-xs text-primary">Edit Area</span></div>
                                <div class="grid grid-cols-2 gap-2">
                                    <div class="bg-primary/10 border border-primary rounded-lg p-3 text-center"><i class="fas fa-crown text-primary mb-1"></i><p class="text-xs font-bold">VIP-1</p><p class="text-[10px] text-gray-500">8 kursi • Private</p></div>
                                    <div class="bg-primary/10 border border-primary rounded-lg p-3 text-center"><i class="fas fa-crown text-primary mb-1"></i><p class="text-xs font-bold">VIP-2</p><p class="text-[10px] text-gray-500">6 kursi • Private</p></div>
                                </div>
                            </div>
                            <button class="w-full py-3 border-2 border-dashed border-gray-300 rounded-xl text-gray-500 text-sm font-medium"><i class="fas fa-plus mr-2"></i>Tambah Area Baru</button>
                        </div>
                    </div>
                </div>
                <!-- User Management -->
                <div>
                    <div class="section-label">4E. Kelola User & Kasir</div>
                    <div class="phone-frame bg-gray-50 relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white">
                            <div class="flex justify-between items-center"><h2 class="font-bold text-lg">Kelola User</h2><button class="px-3 py-1.5 bg-primary text-white rounded-lg text-xs font-medium"><i class="fas fa-plus mr-1"></i>Kasir Baru</button></div>
                            <div class="flex gap-2 mt-3 overflow-x-auto scroll-hide pb-1">
                                <span class="px-4 py-1.5 bg-primary text-white rounded-full text-xs font-medium whitespace-nowrap">Semua (156)</span>
                                <span class="px-4 py-1.5 bg-gray-100 rounded-full text-xs font-medium whitespace-nowrap text-gray-600">Customer (148)</span>
                                <span class="px-4 py-1.5 bg-gray-100 rounded-full text-xs font-medium whitespace-nowrap text-gray-600">Kasir (8)</span>
                            </div>
                        </div>
                        <div class="h-[calc(100%-200px)] overflow-y-auto scroll-hide px-5 pt-3 space-y-3">
                            <div class="bg-white rounded-xl p-3 flex items-center gap-3 shadow-sm">
                                <div class="w-10 h-10 bg-primary rounded-full flex items-center justify-center text-white font-bold text-sm">JD</div>
                                <div class="flex-1"><p class="text-sm font-medium">John Doe</p><p class="text-xs text-gray-400">john@email.com • Customer</p></div>
                                <button class="text-gray-400"><i class="fas fa-ellipsis-v text-xs"></i></button>
                            </div>
                            <div class="bg-white rounded-xl p-3 flex items-center gap-3 shadow-sm">
                                <div class="w-10 h-10 bg-warning rounded-full flex items-center justify-center text-white font-bold text-sm">AS</div>
                                <div class="flex-1"><p class="text-sm font-medium">Ahmad Surya</p><p class="text-xs text-gray-400">ahmad@nrelazio.com • Kasir</p></div>
                                <button class="text-gray-400"><i class="fas fa-ellipsis-v text-xs"></i></button>
                            </div>
                            <div class="bg-white rounded-xl p-3 flex items-center gap-3 shadow-sm">
                                <div class="w-10 h-10 bg-info rounded-full flex items-center justify-center text-white font-bold text-sm">RN</div>
                                <div class="flex-1"><p class="text-sm font-medium">Rina Novita</p><p class="text-xs text-gray-400">rina@nrelazio.com • Kasir</p></div>
                                <button class="text-gray-400"><i class="fas fa-ellipsis-v text-xs"></i></button>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Reports -->
                <div>
                    <div class="section-label">4F. Laporan & Export</div>
                    <div class="phone-frame bg-gray-50 relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white">
                            <div class="flex items-center gap-3"><button class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center"><i class="fas fa-arrow-left text-sm"></i></button><h2 class="font-bold text-lg">Laporan</h2></div>
                        </div>
                        <div class="h-[calc(100%-140px)] overflow-y-auto scroll-hide px-5 pt-3 space-y-4">
                            <div class="bg-white rounded-xl p-4 shadow-sm">
                                <h4 class="font-semibold text-sm mb-3">Filter Periode</h4>
                                <div class="grid grid-cols-2 gap-3">
                                    <div><label class="text-xs text-gray-500">Dari</label><input type="date" value="2024-05-01" class="w-full bg-gray-100 rounded-xl py-2 px-3 text-sm mt-1 outline-none"></div>
                                    <div><label class="text-xs text-gray-500">Sampai</label><input type="date" value="2024-05-10" class="w-full bg-gray-100 rounded-xl py-2 px-3 text-sm mt-1 outline-none"></div>
                                </div>
                            </div>
                            <div class="bg-white rounded-xl p-4 shadow-sm">
                                <div class="flex justify-between items-center mb-3"><h4 class="font-semibold text-sm">Ringkasan</h4><button class="px-3 py-1.5 bg-success/10 text-success rounded-lg text-xs font-medium"><i class="fas fa-download mr-1"></i>CSV</button></div>
                                <div class="space-y-3">
                                    <div class="flex justify-between items-center"><span class="text-sm text-gray-600">Total Transaksi</span><span class="font-bold text-sm">156</span></div>
                                    <div class="flex justify-between items-center"><span class="text-sm text-gray-600">Pendapatan</span><span class="font-bold text-sm text-primary">Rp 15.4jt</span></div>
                                    <div class="flex justify-between items-center"><span class="text-sm text-gray-600">Rata-rata Order</span><span class="font-bold text-sm">Rp 98.700</span></div>
                                    <div class="border-t pt-3"><p class="text-xs text-gray-500 mb-2">Revenue per Kategori</p><div class="space-y-2"><div class="flex items-center gap-2"><div class="w-20 text-xs text-gray-600">Main Course</div><div class="flex-1 h-2 bg-gray-100 rounded-full overflow-hidden"><div class="h-full bg-primary rounded-full" style="width: 65%"></div></div><span class="text-xs font-medium w-12 text-right">65%</span></div><div class="flex items-center gap-2"><div class="w-20 text-xs text-gray-600">Beverages</div><div class="flex-1 h-2 bg-gray-100 rounded-full overflow-hidden"><div class="h-full bg-info rounded-full" style="width: 25%"></div></div><span class="text-xs font-medium w-12 text-right">25%</span></div><div class="flex items-center gap-2"><div class="w-20 text-xs text-gray-600">Dessert</div><div class="flex-1 h-2 bg-gray-100 rounded-full overflow-hidden"><div class="h-full bg-purple-400 rounded-full" style="width: 10%"></div></div><span class="text-xs font-medium w-12 text-right">10%</span></div></div></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- App Settings -->
                <div>
                    <div class="section-label">4G. Pengaturan Aplikasi</div>
                    <div class="phone-frame bg-gray-50 relative">
                        <div class="phone-notch"></div>
                        <div class="pt-12 px-5 pb-3 bg-white">
                            <div class="flex items-center gap-3"><button class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center"><i class="fas fa-arrow-left text-sm"></i></button><h2 class="font-bold text-lg">Pengaturan</h2></div>
                        </div>
                        <div class="h-[calc(100%-140px)] overflow-y-auto scroll-hide px-5 pt-3 space-y-4">
                            <div class="bg-white rounded-xl p-4 shadow-sm">
                                <h4 class="font-semibold text-sm mb-3">Banner Promo</h4>
                                <div class="space-y-3">
                                    <div class="flex items-center gap-3"><img src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200" class="w-16 h-10 rounded-lg object-cover"><div class="flex-1"><p class="text-sm font-medium">Weekend Special</p><p class="text-xs text-gray-400">Aktif hingga 31 Mei</p></div><div class="w-11 h-6 bg-primary rounded-full relative"><div class="absolute right-1 top-1 w-4 h-4 bg-white rounded-full"></div></div></div>
                                    <div class="flex items-center gap-3"><div class="w-16 h-10 bg-gray-200 rounded-lg flex items-center justify-center"><i class="fas fa-image text-gray-400 text-xs"></i></div><div class="flex-1"><p class="text-sm font-medium">New Year Promo</p><p class="text-xs text-gray-400">Nonaktif</p></div><div class="w-11 h-6 bg-gray-300 rounded-full relative"><div class="absolute left-1 top-1 w-4 h-4 bg-white rounded-full"></div></div></div>
                                    <button class="w-full py-2 border-2 border-dashed border-gray-300 rounded-xl text-gray-500 text-xs font-medium"><i class="fas fa-plus mr-1"></i>Tambah Banner</button>
                                </div>
                            </div>
                            <div class="bg-white rounded-xl p-4 shadow-sm">
                                <h4 class="font-semibold text-sm mb-3">Jam Operasional</h4>
                                <div class="space-y-2">
                                    <div class="flex justify-between items-center"><span class="text-sm">Senin - Jumat</span><span class="text-sm font-medium">10:00 - 22:00</span></div>
                                    <div class="flex justify-between items-center"><span class="text-sm">Sabtu - Minggu</span><span class="text-sm font-medium">09:00 - 23:00</span></div>
                                </div>
                            </div>
                            <div class="bg-white rounded-xl p-4 shadow-sm">
                                <h4 class="font-semibold text-sm mb-3">Metode Pembayaran</h4>
                                <div class="space-y-2">
                                    <div class="flex justify-between items-center"><div class="flex items-center gap-2"><i class="fas fa-money-bill-wave text-success"></i><span class="text-sm">Tunai</span></div><div class="w-11 h-6 bg-primary rounded-full relative"><div class="absolute right-1 top-1 w-4 h-4 bg-white rounded-full"></div></div></div>
                                    <div class="flex justify-between items-center"><div class="flex items-center gap-2"><i class="fas fa-qrcode text-info"></i><span class="text-sm">QRIS</span></div><div class="w-11 h-6 bg-primary rounded-full relative"><div class="absolute right-1 top-1 w-4 h-4 bg-white rounded-full"></div></div></div>
                                    <div class="flex justify-between items-center"><div class="flex items-center gap-2"><i class="fas fa-credit-card text-warning"></i><span class="text-sm">Kartu Kredit</span></div><div class="w-11 h-6 bg-gray-300 rounded-full relative"><div class="absolute left-1 top-1 w-4 h-4 bg-white rounded-full"></div></div></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
