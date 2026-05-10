// File: backend_api.gs
// Deploy as Web App, Execute as: Me, Who has access: Anyone

// sudah di deploy dan sudah ada data user admin, kasir dan customer
//Super Admin	admin@nrelazion.com	qwerty123	admin
//Nami	kasir@nrelazion.com	kasir098	kasir
//Lupi	lupi@gmail.com	lupi123	customer

function doGet(e) {
  const action = e.parameter.action;
  
  if (action === 'getMenu') {
    return handleGetMenu(e);
  } else if (action === 'getMeja') {
    return handleGetMeja(e);
  } else if (action === 'getOrders') {
    return handleGetOrders(e);
  } else if (action === 'getUsers') {
    return handleGetUsers(e);
  }
  
  return ContentService.createTextOutput(JSON.stringify({
    success: false, 
    message: 'Action GET tidak dikenali'
  })).setMimeType(ContentService.MimeType.JSON);
}

function doPost(e) {
  // Untuk flutter http.post, kadang data masuk di postData.contents
  let data;
  try {
    data = JSON.parse(e.postData.contents);
  } catch (err) {
    return ContentService.createTextOutput(JSON.stringify({success: false, message: 'Invalid JSON payload'}))
      .setMimeType(ContentService.MimeType.JSON);
  }

  const action = data.action;

  if (action === 'login') {
    return handleLogin(data);
  } else if (action === 'addMenu') {
    return handleAddMenu(data);
  } else if (action === 'updateMenu') {
    return handleUpdateMenu(data);
  } else if (action === 'deleteMenu') {
    return handleDeleteMenu(data);
  } else if (action === 'updateOrderStatus') {
    return handleUpdateOrderStatus(data);
  } else if (action === 'updateMejaStatus') {
    return handleUpdateMejaStatus(data);
  } else if (action === 'addMeja') {
    return handleAddMeja(data);
  } else if (action === 'updateMeja') {
    return handleUpdateMeja(data);
  } else if (action === 'deleteMeja') {
    return handleDeleteMeja(data);
  } else if (action === 'addUser') {
    return handleAddUser(data);
  } else if (action === 'updateUser') {
    return handleUpdateUser(data);
  } else if (action === 'deleteUser') {
    return handleDeleteUser(data);
  }

  return ContentService.createTextOutput(JSON.stringify({
    success: false, 
    message: 'Action POST tidak dikenali'
  })).setMimeType(ContentService.MimeType.JSON);
}

// --- HANDLERS ---

function handleLogin(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Users");
  const rows = sheet.getDataRange().getValues();
  
  // Skip header
  for (let i = 1; i < rows.length; i++) {
    const email = String(rows[i][2]).trim();
    const password = String(rows[i][3]);
    
    if (email === String(data.email).trim() && password === String(data.password)) { // Sederhana (tanpa bcrypt)
      const user = {
        id: rows[i][0],
        nama: rows[i][1],
        email: rows[i][2],
        role: rows[i][4],
        telepon: rows[i][5],
        foto_url: rows[i][6]
      };
      return createJsonResponse({success: true, data: user});
    }
  }
  return createJsonResponse({success: false, message: "Email atau password salah"});
}

function handleGetMenu(e) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Menu");
  if (!sheet) return createJsonResponse({success: false, message: "Sheet Menu tidak ditemukan"});
  
  const rows = sheet.getDataRange().getValues();
  const menus = [];
  
  for (let i = 1; i < rows.length; i++) {
    menus.push({
      id: rows[i][0],
      nama: rows[i][1],
      deskripsi: rows[i][2],
      harga: rows[i][3],
      kategori: rows[i][4],
      gambar_url: rows[i][5],
      status_aktif: rows[i][6]
    });
  }
  return createJsonResponse({success: true, data: menus});
}

function handleAddMenu(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Menu");
  
  const id = Utilities.getUuid();
  sheet.appendRow([
    id,
    data.nama,
    data.deskripsi || "",
    data.harga,
    data.kategori,
    data.gambar_url || "",
    data.status_aktif !== undefined ? data.status_aktif : true
  ]);
  
  return createJsonResponse({success: true, message: "Menu berhasil ditambahkan", id: id});
}

function handleUpdateMenu(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Menu");
  const rows = sheet.getDataRange().getValues();
  
  for (let i = 1; i < rows.length; i++) {
    if (rows[i][0] === data.id) {
      const rowIndex = i + 1;
      if (data.nama) sheet.getRange(rowIndex, 2).setValue(data.nama);
      if (data.deskripsi !== undefined) sheet.getRange(rowIndex, 3).setValue(data.deskripsi);
      if (data.harga !== undefined) sheet.getRange(rowIndex, 4).setValue(data.harga);
      if (data.kategori) sheet.getRange(rowIndex, 5).setValue(data.kategori);
      if (data.gambar_url !== undefined) sheet.getRange(rowIndex, 6).setValue(data.gambar_url);
      if (data.status_aktif !== undefined) sheet.getRange(rowIndex, 7).setValue(data.status_aktif);
      
      return createJsonResponse({success: true, message: "Menu berhasil diupdate"});
    }
  }
  return createJsonResponse({success: false, message: "Menu tidak ditemukan"});
}

function handleDeleteMenu(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Menu");
  const rows = sheet.getDataRange().getValues();
  
  for (let i = 1; i < rows.length; i++) {
    if (rows[i][0] === data.id) {
      sheet.deleteRow(i + 1);
      return createJsonResponse({success: true, message: "Menu berhasil dihapus"});
    }
  }
  return createJsonResponse({success: false, message: "Menu tidak ditemukan"});
}

function handleGetOrders(e) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Orders");
  if (!sheet) return createJsonResponse({success: false, message: "Sheet Orders tidak ditemukan"});
  
  const rows = sheet.getDataRange().getValues();
  const orders = [];
  
  // Ambil param filter (opsional)
  const statusFilter = e.parameter.status;
  
  for (let i = rows.length - 1; i >= 1; i--) { // Reverse order (terbaru di atas)
    const status = rows[i][6];
    if (statusFilter && status !== statusFilter && statusFilter !== 'semua') continue;
    
    orders.push({
      id: rows[i][0],
      user_id: rows[i][1],
      kasir_id: rows[i][2],
      meja_id: rows[i][3],
      items_json: rows[i][4],
      total_harga: rows[i][5],
      status: status,
      metode_bayar: rows[i][7],
      catatan: rows[i][8],
      created_at: rows[i][9],
      updated_at: rows[i][10]
    });
  }
  return createJsonResponse({success: true, data: orders});
}

function handleUpdateOrderStatus(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Orders");
  const rows = sheet.getDataRange().getValues();
  
  for (let i = 1; i < rows.length; i++) {
    if (rows[i][0] === data.order_id) {
      sheet.getRange(i + 1, 7).setValue(data.status); // kolom status
      sheet.getRange(i + 1, 11).setValue(new Date().toISOString()); // kolom updated_at
      return createJsonResponse({success: true, message: "Status pesanan diupdate"});
    }
  }
  return createJsonResponse({success: false, message: "Order tidak ditemukan"});
}

function handleGetMeja(e) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Meja");
  if (!sheet) return createJsonResponse({success: false, message: "Sheet Meja tidak ditemukan"});
  
  const rows = sheet.getDataRange().getValues();
  const meja = [];
  for (let i = 1; i < rows.length; i++) {
    meja.push({
      id: rows[i][0],
      area: rows[i][1],
      nomor: rows[i][2],
      kapasitas: rows[i][3],
      status: rows[i][4]
    });
  }
  return createJsonResponse({success: true, data: meja});
}

function handleUpdateMejaStatus(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Meja");
  const rows = sheet.getDataRange().getValues();
  
  for (let i = 1; i < rows.length; i++) {
    if (rows[i][0] === data.meja_id) {
      sheet.getRange(i + 1, 5).setValue(data.status);
      return createJsonResponse({success: true, message: "Status meja diupdate"});
    }
  }
  return createJsonResponse({success: false, message: "Meja tidak ditemukan"});
}

function handleAddMeja(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Meja");
  
  const id = Utilities.getUuid();
  sheet.appendRow([
    id,
    data.area || "",
    data.nomor || "",
    data.kapasitas || 0,
    data.status || "Tersedia"
  ]);
  
  return createJsonResponse({success: true, message: "Meja berhasil ditambahkan", id: id});
}

function handleUpdateMeja(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Meja");
  const rows = sheet.getDataRange().getValues();
  
  for (let i = 1; i < rows.length; i++) {
    if (rows[i][0] === data.id) {
      const rowIndex = i + 1;
      if (data.area !== undefined) sheet.getRange(rowIndex, 2).setValue(data.area);
      if (data.nomor !== undefined) sheet.getRange(rowIndex, 3).setValue(data.nomor);
      if (data.kapasitas !== undefined) sheet.getRange(rowIndex, 4).setValue(data.kapasitas);
      if (data.status !== undefined) sheet.getRange(rowIndex, 5).setValue(data.status);
      
      return createJsonResponse({success: true, message: "Meja berhasil diupdate"});
    }
  }
  return createJsonResponse({success: false, message: "Meja tidak ditemukan"});
}

function handleDeleteMeja(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Meja");
  const rows = sheet.getDataRange().getValues();
  
  for (let i = 1; i < rows.length; i++) {
    if (rows[i][0] === data.id) {
      sheet.deleteRow(i + 1);
      return createJsonResponse({success: true, message: "Meja berhasil dihapus"});
    }
  }
  return createJsonResponse({success: false, message: "Meja tidak ditemukan"});
}

function handleGetUsers(e) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Users");
  if (!sheet) return createJsonResponse({success: false, message: "Sheet Users tidak ditemukan"});
  
  const rows = sheet.getDataRange().getValues();
  const users = [];
  for (let i = 1; i < rows.length; i++) {
    users.push({
      id: rows[i][0],
      nama: rows[i][1],
      email: rows[i][2],
      // jangan kirimkan password ke frontend untuk getUsers
      role: rows[i][4],
      telepon: rows[i][5],
      foto_url: rows[i][6]
    });
  }
  return createJsonResponse({success: true, data: users});
}

function handleAddUser(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Users");
  
  const id = Utilities.getUuid();
  sheet.appendRow([
    id,
    data.nama || "",
    data.email || "",
    data.password || "123456", // default password jika kosong
    data.role || "customer",
    data.telepon || "",
    data.foto_url || ""
  ]);
  
  return createJsonResponse({success: true, message: "User berhasil ditambahkan", id: id});
}

function handleUpdateUser(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Users");
  const rows = sheet.getDataRange().getValues();
  
  for (let i = 1; i < rows.length; i++) {
    if (rows[i][0] === data.id) {
      const rowIndex = i + 1;
      if (data.nama !== undefined) sheet.getRange(rowIndex, 2).setValue(data.nama);
      if (data.email !== undefined) sheet.getRange(rowIndex, 3).setValue(data.email);
      // Update password jika ada input baru (opsional)
      if (data.password !== undefined && data.password !== "") {
        sheet.getRange(rowIndex, 4).setValue(data.password);
      }
      if (data.role !== undefined) sheet.getRange(rowIndex, 5).setValue(data.role);
      if (data.telepon !== undefined) sheet.getRange(rowIndex, 6).setValue(data.telepon);
      if (data.foto_url !== undefined) sheet.getRange(rowIndex, 7).setValue(data.foto_url);
      
      return createJsonResponse({success: true, message: "User berhasil diupdate"});
    }
  }
  return createJsonResponse({success: false, message: "User tidak ditemukan"});
}

function handleDeleteUser(data) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName("Users");
  const rows = sheet.getDataRange().getValues();
  
  for (let i = 1; i < rows.length; i++) {
    if (rows[i][0] === data.id) {
      sheet.deleteRow(i + 1);
      return createJsonResponse({success: true, message: "User berhasil dihapus"});
    }
  }
  return createJsonResponse({success: false, message: "User tidak ditemukan"});
}

// Utility
function createJsonResponse(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}
