import Foundation
import SwiftUI

final class CoinAnalysisApi {
    static let shared = CoinAnalysisApi()
    
    private init() {}
    
    private struct CoinAnalysisApiResponse: Codable {
        var choices: [Choice]
        
        struct Choice: Codable {
            var message: Message
            struct Message: Codable {
                var content: String
            }
        }
    }
    
    private struct ChatMessageApiResponse: Decodable {
        struct Choice: Decodable {
            let delta: Delta
        }
        
        struct Delta: Decodable {
            let content: String
        }
        
        let choices: [Choice]
    }
    
    private let systemPrompt = """
                    You are a professional cryptocurrency analyst specializing in meme coins. 
                    Your expertise includes advanced technical analysis, trend identification, and market psychology. 
                    You analyze price movements, support and resistance levels, and leverage key indicators to determine market sentiment. 
                    You also consider external factors like social media trends, trading volume spikes, whale activity, and market liquidity. 
        
                    Your analysis must be objective, data-driven, and designed to help traders make informed decisions. 
                    Provide a structured breakdown of the coin's technicals, key levels, and potential market moves. 
        """
    
    private let jsonParams = """
                            Please return your analysis **strictly** in the following JSON format with **all fields included**:
                            
                            {
                                "general_trend": "A summary of the current trend (bullish, bearish, or neutral). Include trend strength, recent price movements, and key resistance/support levels.",
                                
                                "indicator_analysis": "A detailed breakdown of at least three indicators (e.g., RSI, MACD, Moving Averages, Bollinger Bands). Explain whether they confirm the trend or signal a reversal.",
                                
                                "chart_pattern": "Identify any recognizable chart patterns (e.g., triangles, head & shoulders, double tops/bottoms). Mention if they indicate a breakout, reversal, or trend continuation.",
                                
                                "future_market_prediction": "Provide a forecast based on technical and market conditions. Include potential price levels, risk factors, and scenarios for traders to watch."
                            }
                            
                            ⚠️ **Your response must always match this exact JSON structure.**
        """
    
    private let sampleJsonPrompt = """
                    {
                        "general_trend": "The meme coin is currently in a short-term uptrend, gaining 18% in the last 24 hours. Trading volume has increased by 120%, suggesting renewed interest. However, there is significant resistance at $0.0012, which has rejected price twice in the past week.",
                        
                        "indicator_analysis": "The RSI is at 68, approaching overbought conditions, indicating potential for a pullback. The 50-day moving average has crossed above the 200-day moving average (Golden Cross), historically signaling a bullish continuation. The MACD histogram is showing increasing bullish momentum, but traders should watch for potential divergence.",
                        
                        "chart_pattern": "A bullish pennant has formed on the 1-hour chart, suggesting a continuation pattern. If price breaks above $0.0012 with strong volume, a move toward $0.0015 is likely. However, failure to break out could lead to a retest of the $0.00085 support level.",
                        
                        "future_market_prediction": "If the coin sustains volume above $0.0012, the next resistance levels are $0.0015 and $0.0018. However, if momentum slows and RSI confirms a bearish divergence, a retracement to $0.0009 or lower could occur. Social sentiment remains positive, but traders should watch for sudden whale sell-offs or external news that could impact price movement."
                    }
        """
    
    private func cleanResponse(_ response: String) -> String {
        var cleanedText = response
        
        cleanedText = cleanedText.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "$1", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "\\*(.*?)\\*", with: "$1", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "###\\s*", with: "", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "(?m)^-\\s", with: "• ", options: .regularExpression)
        
        return cleanedText
    }
    
    private func fetchApiResponse(request: URLRequest) async -> CoinAnalysis? {
        do {
            let (data, _) = try await safeSession().data(for: request)
            
            let responseObject = try JSONDecoder().decode(CoinAnalysisApiResponse.self, from: data)
            
            var messageContent = responseObject.choices.first?.message.content ?? ""
            
            if messageContent.hasPrefix("```json") {
                messageContent = messageContent.replacingOccurrences(of: "```json", with: "")
            }
            if messageContent.hasSuffix("```") {
                messageContent = messageContent.replacingOccurrences(of: "```", with: "")
            }
            if let jsonData = messageContent.data(using: .utf8) {
                let analysis = try JSONDecoder().decode(CoinAnalysis.self, from: jsonData)
                
                return analysis
            } else {
                print("Error: Unable to parse cleaned JSON string")
                return nil
            }
        } catch {
            print("Caught an error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchChatResponse(_ input: String, history: [ChatMessage], images: [String]) async throws -> AsyncThrowingStream<String, Error> {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { throw URLError(.badURL) }
        
        print("=== fetchChatResponse API Request Started ===")
        print("URL: \(url)")
        print("Input: \(input)")
        print("History count: \(history.count)")
        print("Images count: \(images.count)")
        
        var messages: [[String: Any]] = [
            [
                "role": "system",
                "content": systemPrompt
            ]
        ]
        
        history.forEach { chatHistory in
            messages.append([
                "role": "user",
                "content": chatHistory.sendText
            ])
            messages.append([
                "role": "assistant",
                "content": chatHistory.responseText ?? ""
            ])
        }
        
        var userMessageContent: [[String: Any]] = [
            ["type": "text", "text": input],
        ]
        
        images.forEach { image in
            userMessageContent.append(
                ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(image)"]]
            )
        }
        
        messages.append([
            "role": "user",
            "content": userMessageContent,
        ])
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "stream": true,
        ]
        
        print("Request body model: \(requestBody["model"] ?? "unknown")")
        print("Total messages in request: \(messages.count)")
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Consts.shared.openAiApiKey)"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Unable to serialize JSON")
            throw ApiError.encodingFailded
        }
        request.httpBody = jsonData
        
        print("Request body size: \(jsonData.count) bytes")
        
        let (result, response) = try await safeSession().bytes(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("=== HTTP Response Details ===")
            print("Status Code: \(httpResponse.statusCode)")
            print("Headers: \(httpResponse.allHeaderFields)")
            
            if httpResponse.statusCode == 429 {
                print("⚠️ 429 Too Many Requests Error!")
                if let retryAfter = httpResponse.allHeaderFields["Retry-After"] {
                    print("Retry-After header: \(retryAfter)")
                }
                if let rateLimitRemaining = httpResponse.allHeaderFields["X-RateLimit-Remaining"] {
                    print("Rate Limit Remaining: \(rateLimitRemaining)")
                }
                if let rateLimitReset = httpResponse.allHeaderFields["X-RateLimit-Reset"] {
                    print("Rate Limit Reset: \(rateLimitReset)")
                }
            }
        } else {
            print("Invalid response - not an HTTPURLResponse")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            print("⚠️ API Error: Status code \(httpResponse.statusCode)")
            
            var errorBody = ""
            for try await line in result.lines {
                errorBody += line + "\n"
            }
            print("Error response body: \(errorBody)")
            
            throw ApiError.invalidResponse
        }
        
        print("✅ Request successful, starting to stream response...")
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    var lineCount = 0
                    var totalContent = ""
                    
                    for try await line in result.lines {
                        lineCount += 1
                        
                        if line.hasPrefix("data: ") {
                            let dataString = String(line.dropFirst(6))
                            
                            if dataString == "[DONE]" {
                                print("Stream completed with [DONE] marker")
                                break
                            }
                            
                            if let data = dataString.data(using: .utf8) {
                                do {
                                    let response = try JSONDecoder().decode(ChatMessageApiResponse.self, from: data)
                                    if let text = response.choices.first?.delta.content {
                                        totalContent += text
                                        continuation.yield(cleanResponse(text))
                                    }
                                } catch {
                                    print("Failed to decode line \(lineCount): \(dataString)")
                                    print("Decode error: \(error)")
                                }
                            }
                        } else if !line.isEmpty {
                            print("Unexpected line format at line \(lineCount): \(line)")
                        }
                    }
                    
                    print("=== Stream Completed ===")
                    print("Total lines processed: \(lineCount)")
                    print("Total content length: \(totalContent.count) characters")
                    
                    continuation.finish()
                } catch {
                    print("⚠️ Stream error: \(error)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func getChartAnalysis(image: UIImage) async -> CoinAnalysis? {
        guard let base64Image = Utilities.shared.convertImageToBase64(image: image) else {
            print("Failed to convert image to Base64")
            return nil
        }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Consts.shared.openAiApiKey)"
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": """
                        \(systemPrompt)
                    
                        \(jsonParams)
                    
                        If the provided image cannot be loaded or there is an error with it, please return a **general analysis** of the meme coin and market in the same format (with appropriate dummy content) as shown below:
                    
                        \(sampleJsonPrompt)
                    """,
                ],
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "Analyze the chart and provide key insights, including the meme coin's general trend, indicator analysis, chart pattern, and future market prediction:"],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Unable to serialize JSON")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData
        
        return await fetchApiResponse(request: request)
    }
    
    func getCoinAnalysis(coinData: CoinData, priceList: [Double], timeRange: CoinPriceChartTimeRange) async -> CoinAnalysis? {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Consts.shared.openAiApiKey)"
        ]
        
        let priceListFormatted = priceList.enumerated().map { index, price in
            "\"\(index + 1)\": \(price)"
        }.joined(separator: ", ")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": """
                        \(systemPrompt)
                    
                        \(jsonParams)
                    
                        If insufficient data is provided, return a general market analysis in the same JSON format.
                    
                        \(sampleJsonPrompt)
                    """,
                ],
                [
                    "role": "user",
                    "content": """
                        Analyze the following meme coin information and historical price data:
                        - Coin Name: \(coinData.name)
                        - Symbol: \(coinData.symbol)
                        - Current Price: \(coinData.statistics.price)
                        - Price Change (\(timeRange): \(coinData.getPriceChange(timeRange))%
                        - Volume (24h): $\(coinData.volume)
                        - Price Data (ordered by timestamp): {\(priceListFormatted)}
                        - Date Range: \(timeRange.rawValue)
                        - Market Cap: \(coinData.statistics.fullyDilutedMarketCap)
                    """
                ]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Unable to serialize JSON")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData
        
        return await fetchApiResponse(request: request)
    }
}
