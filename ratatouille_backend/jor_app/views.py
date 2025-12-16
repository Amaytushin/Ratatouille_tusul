from django.shortcuts import render
from rest_framework import viewsets, status
from .serializer import *
from .models import Recipe, Ingredient, Wishlist, User, Nutrition, Category
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny

# 🔹 Recipe ViewSet
class RecipeViewSet(viewsets.ModelViewSet):
    queryset = Recipe.objects.all().order_by('-created_at')
    serializer_class = RecipeSerializer

    @action(detail=False, methods=['get'])
    def by_category(self, request):
        category_name = request.query_params.get('category')
        if category_name:
            recipes = Recipe.objects.filter(category__name=category_name)
        else:
            recipes = Recipe.objects.all()
        serializer = self.get_serializer(recipes, many=True)
        return Response(serializer.data)

# 🔹 Category ViewSet
class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

# 🔹 Search Recipes API
@api_view(['POST'])
def search_recipes(request):
    """
    Хэрэглэгчийн орцуудыг авч тухайн орцуудыг агуулсан recipe-г буцаах
    """
    selected_ingredients = request.data.get('ingredients', [])
    if not selected_ingredients:
        return Response({"recipes": []})

    recipes = Recipe.objects.filter(
        ingredients__name__in=selected_ingredients
    ).distinct()

    serializer = RecipeSerializer(recipes, many=True, context={'request': request})
    print(serializer.data)
    return Response(serializer.data)

# 🔹 User ViewSet
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    parser_classes = (MultiPartParser, FormParser)

    def get_permissions(self):
        if self.action == "create":
            return [AllowAny()]           # register → нээлттэй
        if self.action in ["me", "me_update"]:
            return [IsAuthenticated()]    # зөвхөн login хэрэглэгч
        return [IsAuthenticated()]

    def get_serializer_class(self):
        if self.action == "create":
            return UserCreateSerializer
        if self.action in ["me_update", "update", "partial_update"]:
            return UserUpdateSerializer
        return UserSerializer

    # GET /users/me/
    @action(detail=False, methods=["get"])
    def me(self, request):
        serializer = UserSerializer(request.user, context={"request": request})
        return Response(serializer.data)

    # PATCH /users/me_update/
    @action(detail=False, methods=["patch", "put"])
    def me_update(self, request):
        serializer = UserUpdateSerializer(
            request.user,
            data=request.data,
            partial=True,
            context={"request": request}
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(UserSerializer(request.user, context={"request": request}).data)

# 🔹 Ingredient ViewSet
class IngredientViewSet(viewsets.ModelViewSet):
    queryset = Ingredient.objects.all()
    serializer_class = IngredientSerializer

# 🔹 Wishlist ViewSet
# class WishlistViewSet(viewsets.ModelViewSet):
#     queryset = Wishlist.objects.all()
#     serializer_class = WishlistSerializer
#     permission_classes = [IsAuthenticated]

#     # GET /wishlist/my/  — Login хэрэглэгчийн wishlist авах
#     @action(detail=False, methods=['get'])
#     def my(self, request):
#         wish = Wishlist.objects.filter(user=request.user)
#         serializer = WishlistSerializer(wish, many=True, context={'request': request})
#         return Response(serializer.data)

#     # POST /wishlist/add/
# @action(detail=False, methods=['post'])
# def add(self, request):
#     recipe_id = request.data.get("recipe_id")
#     if not recipe_id:
#         return Response({"error": "recipe_id is required"}, status=400)

#     exists = Wishlist.objects.filter(user=request.user, recipe_id=recipe_id).exists()
#     if exists:
#         return Response({"message": "Already added to wishlist"}, status=200)

#     wishlist = Wishlist.objects.create(user=request.user, recipe_id=recipe_id)
#     serializer = WishlistSerializer(wishlist, context={'request': request})
#     return Response(serializer.data, status=status.HTTP_201_CREATED)

# # DELETE /wishlist/remove/<pk>/
# @action(detail=True, methods=['delete'])
# def remove(self, request, pk=None):
#     try:
#         item = Wishlist.objects.get(id=pk, user=request.user)
#     except Wishlist.DoesNotExist:
#         return Response({"error": "Not found"}, status=404)

#     item.delete()
#     return Response({"message": "Removed"}, status=204)


# 🔹 Nutrition ViewSet
class NutritionViewSet(viewsets.ModelViewSet):
    queryset = Nutrition.objects.all()
    serializer_class = NutritionSerializer

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_wishlist(request):
    user = request.user
    wishlist = Wishlist.objects.filter(user=user)
    serializer = WishlistSerializer(wishlist, many=True)
    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_wishlist(request):
    user = request.user
    recipe_id = request.data.get("recipe_id")
    if not recipe_id:
        return Response({"error": "recipe_id is required"}, status=status.HTTP_400_BAD_REQUEST)
    
    recipe = Recipe.objects.get(id=recipe_id)
    wishlist_item, created = Wishlist.objects.get_or_create(user=user, recipe=recipe)
    serializer = WishlistSerializer(wishlist_item)
    return Response(serializer.data, status=status.HTTP_201_CREATED)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def remove_wishlist(request, pk):
    user = request.user
    try:
        wishlist_item = Wishlist.objects.get(id=pk, user=user)
        wishlist_item.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    except Wishlist.DoesNotExist:
        return Response({"error": "Not found"}, status=status.HTTP_404_NOT_FOUND)