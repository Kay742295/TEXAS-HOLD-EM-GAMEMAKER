// 尝试创建服务器并检查是否成功创建
while (port < 65535 && socket < 0 && attempts < max_attempts) {
    socket = network_create_server(network_socket_tcp, port, 5);
    if (socket >= 0) {
        show_debug_message("Server successfully created on port: " + string(port));
        serverPort = port;  // 记录成功的端口
        break;  // 成功创建服务器，退出循环
    } else {
        port++;  // 如果当前端口不可用，尝试下一个端口
        attempts++;
    }
}

if (socket < 0) {
    show_debug_message("Failed to create server after " + string(max_attempts) + " attempts.");
}
