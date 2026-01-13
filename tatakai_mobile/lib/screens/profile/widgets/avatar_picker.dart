import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/models/image_models.dart';
import 'package:tatakai_mobile/services/image_service.dart';

class AvatarPicker extends StatefulWidget {
  final String type; // 'avatar' or 'banner'
  final Function(String) onImageSelected;

  const AvatarPicker({
    super.key,
    required this.type,
    required this.onImageSelected,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  final ImageService _imageService = ImageService();
  List<AnimeImage> _images = [];
  bool _isLoading = true;
  String _genderFilter = 'any';
  String? _selectedImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final images = await _imageService.fetchRandomImages(
        type: widget.type,
        gender: _genderFilter,
        limit: widget.type == 'banner' ? 8 : 12,
      );
      if (mounted) {
        setState(() {
          _images = images;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      decoration: const BoxDecoration(
        color: AppThemes.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppThemes.radiusXLarge)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                widget.type == 'avatar' ? Icons.face : Icons.image,
                color: AppThemes.accentPink,
              ),
              const SizedBox(width: AppThemes.spaceMd),
              Expanded(
                child: Text(
                  'Choose ${widget.type == 'avatar' ? 'Profile Picture' : 'Banner'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _isLoading ? null : _fetchImages,
              ),
            ],
          ),
          
          if (widget.type == 'avatar') ...[
            const SizedBox(height: AppThemes.spaceMd),
            // Gender Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'any'),
                  const SizedBox(width: AppThemes.spaceSm),
                  _buildFilterChip('Male', 'male'),
                  const SizedBox(width: AppThemes.spaceSm),
                  _buildFilterChip('Female', 'female'),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: AppThemes.spaceLg),
          
          // Grid
          if (_isLoading)
            const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: AppThemes.accentPink),
              ),
            )
          else if (_images.isEmpty)
            const SizedBox(
              height: 200,
              child: Center(
                child: Text('No images found', style: TextStyle(color: Colors.white54)),
              ),
            )
          else
            SizedBox(
              height: 300,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.type == 'avatar' ? 3 : 2,
                  crossAxisSpacing: AppThemes.spaceSm,
                  mainAxisSpacing: AppThemes.spaceSm,
                  childAspectRatio: widget.type == 'avatar' ? 1 : 16/9,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final image = _images[index];
                  final isSelected = _selectedImageUrl == image.url;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedImageUrl = image.url);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                        border: isSelected
                            ? Border.all(color: AppThemes.accentPink, width: 3)
                            : null,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: image.url,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppThemes.darkBackground),
                          ),
                          if (isSelected)
                            Container(
                              color: AppThemes.accentPink.withOpacity(0.3),
                              child: const Center(
                                child: Icon(Icons.check, color: Colors.white, size: 32),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
          const SizedBox(height: AppThemes.spaceLg),
          
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              ),
              const SizedBox(width: AppThemes.spaceMd),
              ElevatedButton(
                onPressed: _selectedImageUrl == null
                    ? null
                    : () {
                        widget.onImageSelected(_selectedImageUrl!);
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemes.accentPink,
                  disabledBackgroundColor: AppThemes.accentPink.withOpacity(0.5),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: AppThemes.spaceLg),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _genderFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _genderFilter = value;
          _fetchImages();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppThemes.accentPink : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
